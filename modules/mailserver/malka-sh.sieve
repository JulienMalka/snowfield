require ["variables", "fileinto", "envelope", "subaddress", "mailbox"];

# rule:[FRnOG]
if allof (header :contains "subject" "[FRnOG]")
{
	fileinto "INBOX.FRnOG";
}
# rule:[dn42]
if allof (header :contains "subject" "[dn42]")
{
	fileinto "INBOX.dn42";
}
# rule:[Lobsters]
if allof (header :is "to" "lobsters-hQ3nfqM88Q@lobste.rs")
{
	fileinto "INBOX.Lobsters";
}
# rule:[Fosdem]
if allof (header :contains "subject" "[devroom-managers]")
{
	fileinto "INBOX.FOSDEM";
}
# rule:[Promox]
if allof (header :contains "subject" "[pve-devel]")
{
	fileinto "INBOX.Proxmox";
}
# rule:[Github]
if allof (header :contains "from" "notifications@github.com")
{
	fileinto "INBOX.Github";
}
# rule:[Netdata]
if allof (header :contains "from" "netdata")
{
	fileinto "INBOX.Netdata";
}
#rule:[Lol]
if header :matches "X-Original-To" "*@malka.sh" {
    set "name" "${1}";
  }

  if string :is "${name}" "" {
    fileinto "INBOX";
  } else {
    fileinto :create "INBOX.${name}";
  }
