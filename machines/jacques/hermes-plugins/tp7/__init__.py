"""TP-7 voice notes as Signal messages.

A note arrives as a POST signed like hermes' generic webhook V2 scheme: hex
HMAC-SHA256 of ``<timestamp>.<body>`` in ``X-Webhook-Signature-V2``, the
timestamp in ``X-Webhook-Timestamp``, and the S3 key of the take in
``X-Request-ID``. The text is handed to the Signal adapter under the source of
the Signal home channel, which is Julien's direct chat, so it lands in that
session as if he had typed it, and the reply goes out through Signal as usual.

config.yaml ``platforms.tp7.extra``: ``port`` (default 8645), ``host``
(default every address), ``secret`` (required).
"""

import json
import logging
from typing import Any, Dict, Optional

from aiohttp import web

from gateway.config import Platform, PlatformConfig
from gateway.platforms.base import BasePlatformAdapter, SendResult
from gateway.platforms.event import MessageEvent, MessageType
from gateway.platforms.helpers import MessageDeduplicator
from gateway.platforms.webhook import _hex_hmac, _hmac_str_equal, _timestamp_fresh

logger = logging.getLogger(__name__)

DEFAULT_PORT = 8645
MAX_BODY_BYTES = 256 * 1024


def _note_text(payload: Dict[str, Any]) -> str:
    text = str(payload.get("text") or "").strip()
    return f"🎙️ (voice note from my TP-7, transcribed automatically)\n\n{text}" if text else ""


class TP7Adapter(BasePlatformAdapter):
    def __init__(self, config: PlatformConfig):
        super().__init__(config=config, platform=Platform("tp7"))
        extra = config.extra or {}
        self._host: Optional[str] = extra.get("host") or None
        self._port = int(extra.get("port", DEFAULT_PORT))
        self._secret = str(extra.get("secret") or "")
        self._runner: Optional[web.AppRunner] = None
        self._seen = MessageDeduplicator(max_size=1000, ttl_seconds=7 * 24 * 3600)

    async def connect(self, *, is_reconnect: bool = False) -> bool:
        if not self._secret:
            logger.error("[tp7] no secret configured, refusing to listen")
            return False
        app = web.Application(client_max_size=MAX_BODY_BYTES)
        app.router.add_post("/note", self._handle_note)
        self._runner = web.AppRunner(app)
        await self._runner.setup()
        await web.TCPSite(self._runner, self._host, self._port).start()
        self._mark_connected()
        logger.info("[tp7] listening on %s:%d", self._host or "*", self._port)
        return True

    async def disconnect(self) -> None:
        self._mark_disconnected()
        if self._runner:
            await self._runner.cleanup()
            self._runner = None

    async def send(self, chat_id: str, content: str, reply_to: Optional[str] = None,
                   metadata: Optional[Dict[str, Any]] = None) -> SendResult:
        return SendResult(success=False, error="tp7 is inbound only; replies go out through Signal")

    async def get_chat_info(self, chat_id: str) -> Dict[str, Any]:
        return {"name": "TP-7", "type": "dm"}

    def _signed(self, request: web.Request, body: bytes) -> bool:
        signature = request.headers.get("X-Webhook-Signature-V2", "")
        timestamp = request.headers.get("X-Webhook-Timestamp", "")
        if not signature or not timestamp:
            return False
        if not _timestamp_fresh(timestamp, "[tp7] signature timestamp outside the replay window"):
            return False
        return _hmac_str_equal(signature, _hex_hmac(self._secret, timestamp.encode() + b"." + body))

    async def _handle_note(self, request: web.Request) -> web.Response:
        body = await request.read()
        if not self._signed(request, body):
            logger.warning("[tp7] rejected a note with a missing or bad signature")
            return web.json_response({"error": "bad signature"}, status=401)
        try:
            payload = json.loads(body)
        except ValueError:
            return web.json_response({"error": "body is not JSON"}, status=400)
        text = _note_text(payload)
        if not text:
            return web.json_response({"status": "ignored", "reason": "empty"})

        note_id = request.headers.get("X-Request-ID") or str(payload.get("key") or "")
        if note_id and self._seen.is_duplicate(note_id):
            return web.json_response({"status": "duplicate"})

        runner = self.gateway_runner
        signal = runner._authorization_adapter(Platform.SIGNAL, None) if runner else None
        home = runner.config.get_home_channel(Platform.SIGNAL) if runner else None
        if signal is None or home is None:
            logger.error("[tp7] no Signal adapter or Signal home channel to deliver into")
            return web.json_response({"error": "signal unavailable"}, status=503)

        source = signal.build_source(
            chat_id=home.chat_id, chat_name=home.name, chat_type="dm",
            user_id=home.chat_id, user_name=home.name, user_id_alt=home.chat_id)
        event = MessageEvent(text=text, message_type=MessageType.TEXT, source=source,
                             message_id=note_id or None, raw_message={"tp7": payload})
        logger.info("[tp7] note %s handed to Signal chat %s", note_id, home.chat_id[:8])
        await signal.handle_message(event)
        return web.json_response({"status": "accepted"}, status=202)


def _configured(cfg) -> bool:
    return bool((getattr(cfg, "extra", None) or {}).get("secret"))


def register(ctx) -> None:
    ctx.register_platform(
        name="tp7", label="TP-7 voice notes", adapter_factory=lambda cfg: TP7Adapter(cfg),
        check_fn=lambda: True, validate_config=_configured, is_connected=_configured, emoji="🎙️")
