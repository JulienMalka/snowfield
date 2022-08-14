{composerEnv, fetchurl, fetchgit ? null, fetchhg ? null, fetchsvn ? null, noDev ? false}:

let
  packages = {
    "composer/ca-bundle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-ca-bundle-78a0e288fdcebf92aa2318a8d3656168da6ac1a5";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/ca-bundle/zipball/78a0e288fdcebf92aa2318a8d3656168da6ac1a5";
          sha256 = "0fqx8cn7b0mrc7mvp8mdrl4g0y65br6wrbhizp4mk1qc7rf0xrvk";
        };
      };
    };
    "danielstjules/stringy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "danielstjules-stringy-4749c205db47ee5b32e8d1adf6d9aff8db6caf3b";
        src = fetchurl {
          url = "https://api.github.com/repos/danielstjules/Stringy/zipball/4749c205db47ee5b32e8d1adf6d9aff8db6caf3b";
          sha256 = "0iwsm34kicgfxpr3icifbqvcw1h822rvns57g5vam46wqsa51gwk";
        };
      };
    };
    "doctrine/annotations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-annotations-ce77a7ba1770462cd705a91a151b6c3746f9c6ad";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/annotations/zipball/ce77a7ba1770462cd705a91a151b6c3746f9c6ad";
          sha256 = "1gyiq27jg7n0p4wyx7qbcv8kfwacx25jpsnlqiyi3zbrqcb8ajn4";
        };
      };
    };
    "doctrine/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-cache-13e3381b25847283a91948d04640543941309727";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/cache/zipball/13e3381b25847283a91948d04640543941309727";
          sha256 = "088fxbpjssp8x95qr3ip2iynxrimimrby03xlsvp2254vcyx94c5";
        };
      };
    };
    "doctrine/collections" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-collections-55f8b799269a1a472457bd1a41b4f379d4cfba4a";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/collections/zipball/55f8b799269a1a472457bd1a41b4f379d4cfba4a";
          sha256 = "1kalndrc2g8g82524yg0rcn4xzrl5a9hi0x6g6ixqa6afzgzmvbs";
        };
      };
    };
    "doctrine/common" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-common-4acb8f89626baafede6ee5475bc5844096eba8a9";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/common/zipball/4acb8f89626baafede6ee5475bc5844096eba8a9";
          sha256 = "0qjqframvg81z3lwqaj5haanqj9v3dfbj170pxmwlgmrfsbr16zh";
        };
      };
    };
    "doctrine/dbal" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-dbal-1b1effbddbdc0f40d1c8f849f44bcddac4f52a48";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/dbal/zipball/1b1effbddbdc0f40d1c8f849f44bcddac4f52a48";
          sha256 = "0lay6adkkgq4rl88qy5rifzhfl65ynhcdal826kn8d5x9xxzwwjj";
        };
      };
    };
    "doctrine/inflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-inflector-4650c8b30c753a76bf44fb2ed00117d6f367490c";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/inflector/zipball/4650c8b30c753a76bf44fb2ed00117d6f367490c";
          sha256 = "13jnzwpzz63i6zipmhb22lv35l5gq6wmji0532c94331wcq5bvv9";
        };
      };
    };
    "doctrine/lexer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-lexer-e864bbf5904cb8f5bb334f99209b48018522f042";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/lexer/zipball/e864bbf5904cb8f5bb334f99209b48018522f042";
          sha256 = "11lg9fcy0crb8inklajhx3kyffdbx7xzdj8kwl21xsgq9nm9iwvv";
        };
      };
    };
    "geoip2/geoip2" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "geoip2-geoip2-d01be5894a5c1a3381c58c9b1795cd07f96c30f7";
        src = fetchurl {
          url = "https://api.github.com/repos/maxmind/GeoIP2-php/zipball/d01be5894a5c1a3381c58c9b1795cd07f96c30f7";
          sha256 = "041yrdkgqfx3bv2shr24c5zdmwy9j3zgi7395vsd9sfg0ya0pf4g";
        };
      };
    };
    "google/recaptcha" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "google-recaptcha-614f25a9038be4f3f2da7cbfd778dc5b357d2419";
        src = fetchurl {
          url = "https://api.github.com/repos/google/recaptcha/zipball/614f25a9038be4f3f2da7cbfd778dc5b357d2419";
          sha256 = "0a3457ymsxrp49f2qa4l3v60dncnfac1s6gv0i7clwk86r7d8pk1";
        };
      };
    };
    "illuminate/auth" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-auth-50824f5fccf42070e6801b6a04bb7c6f32ed578b";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/auth/zipball/50824f5fccf42070e6801b6a04bb7c6f32ed578b";
          sha256 = "1zp5j1bgbriqg8mqp79nkldksqbqv8hvvmrivpxynq04k3wp15q7";
        };
      };
    };
    "illuminate/broadcasting" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-broadcasting-b376365db87b1aeb6277671f0ab4bd1a687edd35";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/broadcasting/zipball/b376365db87b1aeb6277671f0ab4bd1a687edd35";
          sha256 = "080h5nspwd0khb4npd2b6vgnsvsnnz399m0xilpipzg3k0x7c3k6";
        };
      };
    };
    "illuminate/bus" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-bus-6637c1347dc3c57c2808705e7fe80ac733c73939";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/bus/zipball/6637c1347dc3c57c2808705e7fe80ac733c73939";
          sha256 = "0458q03zm6pdaqncqqiaqm85mhx4brszbsn57h59wlv80v5aiynb";
        };
      };
    };
    "illuminate/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-cache-d499f629bdefc9d14882b423137ead66bb7f3350";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/cache/zipball/d499f629bdefc9d14882b423137ead66bb7f3350";
          sha256 = "1yxqb3vj9qg2k8411vlk6ihyr5p7la7i44c53g79f5dm09lhc6xj";
        };
      };
    };
    "illuminate/config" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-config-b0bb52f9004a09920cf235b3ed1481355360b70f";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/config/zipball/b0bb52f9004a09920cf235b3ed1481355360b70f";
          sha256 = "10v78nwgmlp5lh19wp8rm9a83ahi34rsljz4lwj01h6p2kzad93i";
        };
      };
    };
    "illuminate/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-console-cde6c371180ca25d700d5ab5dc642f5712eacf2f";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/console/zipball/cde6c371180ca25d700d5ab5dc642f5712eacf2f";
          sha256 = "1g55kklb51b91jmjc8nz329vbfgijj4bg7ai46vzbby3cy81q999";
        };
      };
    };
    "illuminate/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-container-237de3cedbca9b753f2ee69bc7145ae159b8cc96";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/container/zipball/237de3cedbca9b753f2ee69bc7145ae159b8cc96";
          sha256 = "1xdwjpf3qhvhxy9r17d78z9y7g1c01rbkyfwn3r355xbw23n1bbj";
        };
      };
    };
    "illuminate/contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-contracts-6e828a355b7a467232efad3dbe76df17463178e3";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/contracts/zipball/6e828a355b7a467232efad3dbe76df17463178e3";
          sha256 = "0bvj9hxwwgi8ifxj920linp9m867n0f5lf9v7mnka4qfgw16qa0d";
        };
      };
    };
    "illuminate/cookie" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-cookie-16563e04b89837eda43ce343f8623336d94c01ba";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/cookie/zipball/16563e04b89837eda43ce343f8623336d94c01ba";
          sha256 = "0syfg3d7r14gv6bn4ckl9p7zf2an3h0z2i55s4wnjyanmkv0g0s0";
        };
      };
    };
    "illuminate/database" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-database-d4cd215d18b3ed848384a45764ae71ec89a47f07";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/database/zipball/d4cd215d18b3ed848384a45764ae71ec89a47f07";
          sha256 = "0xxcq3p4ixffa1rw22qfkisbnjxzq48acllalza4s8wcrc4wrdb3";
        };
      };
    };
    "illuminate/encryption" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-encryption-713b6bd42d7e4e0d8cb0e9f79669520cc7e60232";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/encryption/zipball/713b6bd42d7e4e0d8cb0e9f79669520cc7e60232";
          sha256 = "019hwfy4lzjs2jikv0ml3zfwa0ny46bgj3spdc9xdh0lkss33qs6";
        };
      };
    };
    "illuminate/events" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-events-b498088237eb9f6be9725e807e8e01d2631777e9";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/events/zipball/b498088237eb9f6be9725e807e8e01d2631777e9";
          sha256 = "1wys215fsw0i2b6i0z11mb7mk68zgc9ylih4fwcsak6633rn41yf";
        };
      };
    };
    "illuminate/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-filesystem-f109f5fb12eef0211cdaff226bef51e18ec8c147";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/filesystem/zipball/f109f5fb12eef0211cdaff226bef51e18ec8c147";
          sha256 = "15n4xm0pj6065h4grx1kh2y0yddy3p167qqw2imgp6jbqywwfa9w";
        };
      };
    };
    "illuminate/hashing" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-hashing-c2965ffab42f4e34ea243f669439f5f7f08223ad";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/hashing/zipball/c2965ffab42f4e34ea243f669439f5f7f08223ad";
          sha256 = "1c6g4slypp0f6z4hkpbianz2j23kh964qsqgcig80r8k4nysk6gx";
        };
      };
    };
    "illuminate/http" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-http-9f6466e9ad4f4d50afc833b63003e5eebb8a6c7b";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/http/zipball/9f6466e9ad4f4d50afc833b63003e5eebb8a6c7b";
          sha256 = "09drvivxvvh8w5s85qcjhg4ynyjjiar2gx8r4lssil2qndqgmk5n";
        };
      };
    };
    "illuminate/mail" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-mail-2d36d016f366d8d381d9c2c3cc164469d66ac9f4";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/mail/zipball/2d36d016f366d8d381d9c2c3cc164469d66ac9f4";
          sha256 = "1hvf8scs7k9z20c2ls84ihhnrqn2q3jkk6dx255jk0lrzgwr7fr4";
        };
      };
    };
    "illuminate/pagination" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-pagination-0e25c18fa0d50c97132d3d0b2eb9d566005ffce3";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/pagination/zipball/0e25c18fa0d50c97132d3d0b2eb9d566005ffce3";
          sha256 = "07lx6dbv8cb72rybx667jb95wjdvic4hqv7s7ikmfxlq84n8fpbw";
        };
      };
    };
    "illuminate/pipeline" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-pipeline-ce96681a13cc7005954a14b3f6ee93ac54aa2ded";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/pipeline/zipball/ce96681a13cc7005954a14b3f6ee93ac54aa2ded";
          sha256 = "0bjwqki1v2wjvbw0nab126kdlyc52cifssvz0z752mxrc1jna3c2";
        };
      };
    };
    "illuminate/queue" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-queue-c3ba6e600bec0aa3daf1aeb9a890e095cc546cf4";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/queue/zipball/c3ba6e600bec0aa3daf1aeb9a890e095cc546cf4";
          sha256 = "16wg7x008lai682kasdlhc2ivhhnylb22dicizhf08blspkbdndm";
        };
      };
    };
    "illuminate/routing" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-routing-ef56e4b751fd0cd1eae065e6bab108f1fcf748fe";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/routing/zipball/ef56e4b751fd0cd1eae065e6bab108f1fcf748fe";
          sha256 = "18w5vsm51qg4r88w9nr19831rdvhqlfiq5sqqi7w5kw2s569qiw8";
        };
      };
    };
    "illuminate/session" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-session-7b953bad4caf213497bfe6fae0250ad14cd74b82";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/session/zipball/7b953bad4caf213497bfe6fae0250ad14cd74b82";
          sha256 = "1vxdzxycfga8h513y3bxmy9kv997vgr1p29lln2zl9d828x1pwwq";
        };
      };
    };
    "illuminate/support" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-support-510163046dc50a467621448d6905f0c819ee8b4a";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/support/zipball/510163046dc50a467621448d6905f0c819ee8b4a";
          sha256 = "1rhh335zbq7xg12m77dvql6di5n8cx68dbh16jpb0xv7aq36grfx";
        };
      };
    };
    "illuminate/translation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-translation-11fa64ecc8c533f8a6845c05d1ad2efc34726e11";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/translation/zipball/11fa64ecc8c533f8a6845c05d1ad2efc34726e11";
          sha256 = "00yx6g9pxv1hb9vhhf6j808s71sah4qm5h5apgi50phrvq8ygwq9";
        };
      };
    };
    "illuminate/validation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-validation-aff98791ccfc8a129a19b83fdc257510bdaf1c3f";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/validation/zipball/aff98791ccfc8a129a19b83fdc257510bdaf1c3f";
          sha256 = "0bg01hy6lha9fs61srxh9zaa0ifig00lm5m7yrky0yw5qvx2mls4";
        };
      };
    };
    "illuminate/view" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-view-8dc810083f5c0dc889757d62be65a7307d92a30b";
        src = fetchurl {
          url = "https://api.github.com/repos/illuminate/view/zipball/8dc810083f5c0dc889757d62be65a7307d92a30b";
          sha256 = "08yaigwmjb5hl8hj8q1ai2cshrn1p1zl01zmddgvq01c5s4pyis8";
        };
      };
    };
    "jeremeamia/superclosure" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jeremeamia-superclosure-5707d5821b30b9a07acfb4d76949784aaa0e9ce9";
        src = fetchurl {
          url = "https://api.github.com/repos/jeremeamia/super_closure/zipball/5707d5821b30b9a07acfb4d76949784aaa0e9ce9";
          sha256 = "0jhj9s4fkv5lqpjs0r80czq2s8wv4i2ilaav9pkbwrpk17q9dh0c";
        };
      };
    };
    "kylekatarnls/update-helper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "kylekatarnls-update-helper-429be50660ed8a196e0798e5939760f168ec8ce9";
        src = fetchurl {
          url = "https://api.github.com/repos/kylekatarnls/update-helper/zipball/429be50660ed8a196e0798e5939760f168ec8ce9";
          sha256 = "02lzagbgykk5bqqa203vkyh6xxblvsg6d8sfgsrzp0g228my4qpz";
        };
      };
    };
    "laravel/lumen-framework" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-lumen-framework-105029d56ea0de66a9528100de7acd5cfacf0116";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/lumen-framework/zipball/105029d56ea0de66a9528100de7acd5cfacf0116";
          sha256 = "0p2c8l5sfnfv8a19w8qw86qi8fh2hww6xmzk7klkh9ks2y4zxf33";
        };
      };
    };
    "laravelcollective/html" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravelcollective-html-99342cc22507cf8d7178bb390c215968183993bb";
        src = fetchurl {
          url = "https://api.github.com/repos/LaravelCollective/html/zipball/99342cc22507cf8d7178bb390c215968183993bb";
          sha256 = "132xvr8yhfq6bl9gwabl9lis3zpzzsxysc41jxq6c3xf9hhi03l8";
        };
      };
    };
    "league/fractal" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-fractal-06dc15f6ba38f2dde2f919d3095d13b571190a7c";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/fractal/zipball/06dc15f6ba38f2dde2f919d3095d13b571190a7c";
          sha256 = "1pb4nsiq9zppqdgzmw1b01m2xls077zp35i9yzrgaiv8bwk790m8";
        };
      };
    };
    "maatwebsite/excel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "maatwebsite-excel-f5540c4ba3ac50cebd98b09ca42e61f926ef299f";
        src = fetchurl {
          url = "https://api.github.com/repos/Maatwebsite/Laravel-Excel/zipball/f5540c4ba3ac50cebd98b09ca42e61f926ef299f";
          sha256 = "0hb92l68lxpirx27am6jh4q8v4mb94h3r3vvvvqgk8l7byfrp6ll";
        };
      };
    };
    "maxmind-db/reader" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "maxmind-db-reader-9ee9ba9ee287b119e9f5a8e8dbfea0b49647cec4";
        src = fetchurl {
          url = "https://api.github.com/repos/maxmind/MaxMind-DB-Reader-php/zipball/9ee9ba9ee287b119e9f5a8e8dbfea0b49647cec4";
          sha256 = "1c6bzcqmz82canzi1rk36mmjk2c7xdgj0c6gw616bb5iysfard93";
        };
      };
    };
    "maxmind/web-service-common" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "maxmind-web-service-common-32f274051c543fc865e5a84d3a2c703913641ea8";
        src = fetchurl {
          url = "https://api.github.com/repos/maxmind/web-service-common-php/zipball/32f274051c543fc865e5a84d3a2c703913641ea8";
          sha256 = "0cdwff091s661kdl425df54yjlbppp4b1ddn32cy1xw6wsbl2g1f";
        };
      };
    };
    "monolog/monolog" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "monolog-monolog-2209ddd84e7ef1256b7af205d0717fb62cfc9c33";
        src = fetchurl {
          url = "https://api.github.com/repos/Seldaek/monolog/zipball/2209ddd84e7ef1256b7af205d0717fb62cfc9c33";
          sha256 = "1brvym898mjk6yk95b9lzz35ikj1p17gq7zhr0fj1r1sday8rj4c";
        };
      };
    };
    "mtdowling/cron-expression" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "mtdowling-cron-expression-9be552eebcc1ceec9776378f7dcc085246cacca6";
        src = fetchurl {
          url = "https://api.github.com/repos/mtdowling/cron-expression/zipball/9be552eebcc1ceec9776378f7dcc085246cacca6";
          sha256 = "1lsla84mlk1w7lqgqq1flzplx8annld5x02w7acmpn0mrp5r28kn";
        };
      };
    };
    "nesbot/carbon" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nesbot-carbon-4be0c005164249208ce1b5ca633cd57bdd42ff33";
        src = fetchurl {
          url = "https://api.github.com/repos/briannesbitt/Carbon/zipball/4be0c005164249208ce1b5ca633cd57bdd42ff33";
          sha256 = "15vddmcxpzfaglb0w7y49kahppnl7df0smhwpxgy5v05c5c0093a";
        };
      };
    };
    "nikic/fast-route" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-fast-route-f26a8f7788f25c0e3e9b1579d38d7ccab2755320";
        src = fetchurl {
          url = "https://api.github.com/repos/nikic/FastRoute/zipball/f26a8f7788f25c0e3e9b1579d38d7ccab2755320";
          sha256 = "0gjwbdf081p0b6xsxdsxy4h45qdc4729clpc5zjwl66wc2510r17";
        };
      };
    };
    "nikic/php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-php-parser-c6d052fc58cb876152f89f532b95a8d7907e7f0e";
        src = fetchurl {
          url = "https://api.github.com/repos/nikic/PHP-Parser/zipball/c6d052fc58cb876152f89f532b95a8d7907e7f0e";
          sha256 = "1392bj45myazpphic05jxqwlyify72s3qf5vspd991rk5a2p60pw";
        };
      };
    };
    "paragonie/random_compat" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "paragonie-random_compat-9b3899e3c3ddde89016f576edb8c489708ad64cd";
        src = fetchurl {
          url = "https://api.github.com/repos/paragonie/random_compat/zipball/9b3899e3c3ddde89016f576edb8c489708ad64cd";
          sha256 = "1509ii9irfchf64gmbxyknbq9alchxi4m2ayl2l762gzhqryak14";
        };
      };
    };
    "phpoffice/phpexcel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpoffice-phpexcel-1441011fb7ecdd8cc689878f54f8b58a6805f870";
        src = fetchurl {
          url = "https://api.github.com/repos/PHPOffice/PHPExcel/zipball/1441011fb7ecdd8cc689878f54f8b58a6805f870";
          sha256 = "1k0fp9dx09zdh2489b4w1qp0k3n1ad4l6f0kqp3ihb9wp5cvxfba";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-0f73288fd15629204f9d42b7055f72dacbe811fc";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/log/zipball/0f73288fd15629204f9d42b7055f72dacbe811fc";
          sha256 = "1npi9ggl4qll4sdxz1xgp8779ia73gwlpjxbb1f1cpl1wn4s42r4";
        };
      };
    };
    "swiftmailer/swiftmailer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "swiftmailer-swiftmailer-181b89f18a90f8925ef805f950d47a7190e9b950";
        src = fetchurl {
          url = "https://api.github.com/repos/swiftmailer/swiftmailer/zipball/181b89f18a90f8925ef805f950d47a7190e9b950";
          sha256 = "0hkmawv3bhbqdavy4wxqhzajg5zqd7chsi8w27y2zdi5r35az75d";
        };
      };
    };
    "symfony/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-console-574cb4cfaa01ba115fc2fc0c2355b2c5472a4804";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/console/zipball/574cb4cfaa01ba115fc2fc0c2355b2c5472a4804";
          sha256 = "0hx0mxs5zxvw46as109s0s96ymbs7h4xa070f31jlp3qy4lzy0vm";
        };
      };
    };
    "symfony/css-selector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-css-selector-da3d9da2ce0026771f5fe64cb332158f1bd2bc33";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/css-selector/zipball/da3d9da2ce0026771f5fe64cb332158f1bd2bc33";
          sha256 = "0nixkzc1c18jxv0wf1jy6r7pynr2w6p50v1rp9lzfjllxp61kla2";
        };
      };
    };
    "symfony/debug" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-debug-4a7330f29b3d215f8bacf076689f9d1c3d568681";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/debug/zipball/4a7330f29b3d215f8bacf076689f9d1c3d568681";
          sha256 = "0zrjsf3m9zfdaqbm130szkf3ndk5ppfh84bc1hh539lbrij2h21h";
        };
      };
    };
    "symfony/dom-crawler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-dom-crawler-d905e1c5885735ee66af60c205429b9941f24752";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/dom-crawler/zipball/d905e1c5885735ee66af60c205429b9941f24752";
          sha256 = "08fkwsrjzm70zmqb224glrzmz168g0brqwi85spzfr5kimc3s643";
        };
      };
    };
    "symfony/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-a77e974a5fecb4398833b0709210e3d5e334ffb0";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher/zipball/a77e974a5fecb4398833b0709210e3d5e334ffb0";
          sha256 = "1v0hv5ghbrjl3hhvrfhhks1adwms05ybm4yvffwyqqcm77yvv8cg";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-34226a3aa279f1e356ad56181b91acfdc9a2525c";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/finder/zipball/34226a3aa279f1e356ad56181b91acfdc9a2525c";
          sha256 = "1x3vakgr5zg1d35s9qsavslca5z1kcf1bdpj8vyppi7kvn11046n";
        };
      };
    };
    "symfony/http-foundation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-foundation-b67e5cbd2bf837fb3681f2c4965826d6c6758532";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-foundation/zipball/b67e5cbd2bf837fb3681f2c4965826d6c6758532";
          sha256 = "0k5fgpmixr8xk8a72vrsbh9ccgcdjq2apkqs7kfnvmnigb9w204g";
        };
      };
    };
    "symfony/http-kernel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-kernel-435064b3b143f79469206915137c21e88b56bfb9";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-kernel/zipball/435064b3b143f79469206915137c21e88b56bfb9";
          sha256 = "059q50dgx4rrbs2mk7lj81hsbl8xdhnjjw2bx1mxq93yfxsfj7im";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-c6c942b1ac76c82448322025e084cadc56048b4e";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-ctype/zipball/c6c942b1ac76c82448322025e084cadc56048b4e";
          sha256 = "0jpk859wx74vm03q5s9z25f4ak2138p2x5q3b587wvy8rq2m4pbd";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-f377a3dd1fde44d37b9831d68dc8dea3ffd28e13";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-mbstring/zipball/f377a3dd1fde44d37b9831d68dc8dea3ffd28e13";
          sha256 = "0l2adplbn6fw2dj3nm1s2274q25njii18fzvid5lry4bykqxv34k";
        };
      };
    };
    "symfony/polyfill-php56" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php56-54b8cd7e6c1643d78d011f3be89f3ef1f9f4c675";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php56/zipball/54b8cd7e6c1643d78d011f3be89f3ef1f9f4c675";
          sha256 = "0gbw33finml181s3gbvamrsav368rysa8fx69fbq0ff9cvn2lmc6";
        };
      };
    };
    "symfony/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-process-eda637e05670e2afeec3842dcd646dce94262f6b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/process/zipball/eda637e05670e2afeec3842dcd646dce94262f6b";
          sha256 = "1sl0hqdf7zxjlb0j42mfkkdk35wzggq5570qvfjn18x33g85dk0a";
        };
      };
    };
    "symfony/routing" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-routing-33bd5882f201f9a3b7dd9640b95710b71304c4fb";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/routing/zipball/33bd5882f201f9a3b7dd9640b95710b71304c4fb";
          sha256 = "0mf3b8bf61bj75p314s4a1g0kxarsydbkb4qdb2a54g9bk2vbdws";
        };
      };
    };
    "symfony/translation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-1959c78c5a32539ef221b3e18a961a96d949118f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/translation/zipball/1959c78c5a32539ef221b3e18a961a96d949118f";
          sha256 = "08ynfn9kqgspan3mwn7r97g5vlkj4hvh7b1k0qnpam17lqw749vr";
        };
      };
    };
    "symfony/var-dumper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-var-dumper-6f9271e94369db05807b261fcfefe4cd1aafd390";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/var-dumper/zipball/6f9271e94369db05807b261fcfefe4cd1aafd390";
          sha256 = "01hw2fswbi37r91g3gmf43z869bg93yjmrshb36k1d4q5d96dihi";
        };
      };
    };
    "tijsverkoyen/css-to-inline-styles" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tijsverkoyen-css-to-inline-styles-b43b05cf43c1b6d849478965062b6ef73e223bb5";
        src = fetchurl {
          url = "https://api.github.com/repos/tijsverkoyen/CssToInlineStyles/zipball/b43b05cf43c1b6d849478965062b6ef73e223bb5";
          sha256 = "0lc6jviz8faqxxs453dbqvfdmm6l2iczxla22v2r6xhakl58pf3w";
        };
      };
    };
    "torann/geoip" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "torann-geoip-dc3c4fc17779b3521736dd4e04d1fa2dd8f55db9";
        src = fetchurl {
          url = "https://api.github.com/repos/Torann/laravel-geoip/zipball/dc3c4fc17779b3521736dd4e04d1fa2dd8f55db9";
          sha256 = "0vc75d8sqammaf59c73nbhdpfmxayckahiddbhbmvz5kdgzhi54b";
        };
      };
    };
    "vlucas/phpdotenv" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "vlucas-phpdotenv-0cac554ce06277e33ddf9f0b7ade4b8bbf2af3fa";
        src = fetchurl {
          url = "https://api.github.com/repos/vlucas/phpdotenv/zipball/0cac554ce06277e33ddf9f0b7ade4b8bbf2af3fa";
          sha256 = "0fqjmb7wzi0wfg6yvi2y31bpzwida2xgnj4yjxm46wi98q5gqjic";
        };
      };
    };
    "yajra/laravel-datatables-oracle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "yajra-laravel-datatables-oracle-5ccbe38affa0a9930a2add19684e012bed09f62d";
        src = fetchurl {
          url = "https://api.github.com/repos/yajra/laravel-datatables/zipball/5ccbe38affa0a9930a2add19684e012bed09f62d";
          sha256 = "0crr8jpb7bjimpdbskvm83l18mwvj34fsjb659gxvrsb0r01ypk3";
        };
      };
    };
  };
  devPackages = {
    "doctrine/instantiator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-instantiator-d56bf6102915de5702778fe20f2de3b2fe570b5b";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/instantiator/zipball/d56bf6102915de5702778fe20f2de3b2fe570b5b";
          sha256 = "04rihgfjv8alvvb92bnb5qpz8fvqvjwfrawcjw34pfnfx4jflcwh";
        };
      };
    };
    "fzaninotto/faker" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fzaninotto-faker-848d8125239d7dbf8ab25cb7f054f1a630e68c2e";
        src = fetchurl {
          url = "https://api.github.com/repos/fzaninotto/Faker/zipball/848d8125239d7dbf8ab25cb7f054f1a630e68c2e";
          sha256 = "1nsbmkws5lwfm0nhy67q6awzwcb1qxgnqml6yfy3wfj7s62r6x09";
        };
      };
    };
    "myclabs/deep-copy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "myclabs-deep-copy-776f831124e9c62e1a2c601ecc52e776d8bb7220";
        src = fetchurl {
          url = "https://api.github.com/repos/myclabs/DeepCopy/zipball/776f831124e9c62e1a2c601ecc52e776d8bb7220";
          sha256 = "181f3fsxs6s2wyy4y7qfk08qmlbvz1wn3mn3lqy42grsb8g8ym0k";
        };
      };
    };
    "phpdocumentor/reflection-common" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-common-1d01c49d4ed62f25aa84a747ad35d5a16924662b";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/ReflectionCommon/zipball/1d01c49d4ed62f25aa84a747ad35d5a16924662b";
          sha256 = "1wx720a17i24471jf8z499dnkijzb4b8xra11kvw9g9hhzfadz1r";
        };
      };
    };
    "phpdocumentor/reflection-docblock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-docblock-069a785b2141f5bcf49f3e353548dc1cce6df556";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/ReflectionDocBlock/zipball/069a785b2141f5bcf49f3e353548dc1cce6df556";
          sha256 = "0qid63bsfjmc3ka54f1ijl4a5zqwf7jmackjyjmbw3gxdnbi69il";
        };
      };
    };
    "phpdocumentor/type-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-type-resolver-6a467b8989322d92aa1c8bf2bebcc6e5c2ba55c0";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/TypeResolver/zipball/6a467b8989322d92aa1c8bf2bebcc6e5c2ba55c0";
          sha256 = "01g6mihq5wd1396njjb7ibcdfgk26ix1kmbjb6dlshzav0k3983h";
        };
      };
    };
    "phpspec/prophecy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpspec-prophecy-451c3cd1418cf640de218914901e51b064abb093";
        src = fetchurl {
          url = "https://api.github.com/repos/phpspec/prophecy/zipball/451c3cd1418cf640de218914901e51b064abb093";
          sha256 = "0z6wh1lygafcfw36r9abrg7fgq9r3v1233v38g4wbqy3jf7xfrzb";
        };
      };
    };
    "phpunit/php-code-coverage" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-code-coverage-ef7b2f56815df854e66ceaee8ebe9393ae36a40d";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-code-coverage/zipball/ef7b2f56815df854e66ceaee8ebe9393ae36a40d";
          sha256 = "0i6lbr08g63vzd0dh1ax6b0x8m86r79ia7iggx6k42898332qgw3";
        };
      };
    };
    "phpunit/php-file-iterator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-file-iterator-730b01bc3e867237eaac355e06a36b85dd93a8b4";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-file-iterator/zipball/730b01bc3e867237eaac355e06a36b85dd93a8b4";
          sha256 = "0kbg907g9hrx7pv8v0wnf4ifqywdgvigq6y6z00lyhgd0b8is060";
        };
      };
    };
    "phpunit/php-text-template" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-text-template-31f8b717e51d9a2afca6c9f046f5d69fc27c8686";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-text-template/zipball/31f8b717e51d9a2afca6c9f046f5d69fc27c8686";
          sha256 = "1y03m38qqvsbvyakd72v4dram81dw3swyn5jpss153i5nmqr4p76";
        };
      };
    };
    "phpunit/php-timer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-timer-3dcf38ca72b158baf0bc245e9184d3fdffa9c46f";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-timer/zipball/3dcf38ca72b158baf0bc245e9184d3fdffa9c46f";
          sha256 = "1j04r0hqzrv6m1jk5nb92k2nnana72nscqpfk3rgv3fzrrv69ljr";
        };
      };
    };
    "phpunit/php-token-stream" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-token-stream-791198a2c6254db10131eecfe8c06670700904db";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-token-stream/zipball/791198a2c6254db10131eecfe8c06670700904db";
          sha256 = "03i9259r9mjib2ipdkavkq6di66mrsga6kzc7rq5pglrhfiiil4s";
        };
      };
    };
    "phpunit/phpunit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-phpunit-b7803aeca3ccb99ad0a506fa80b64cd6a56bbc0c";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/phpunit/zipball/b7803aeca3ccb99ad0a506fa80b64cd6a56bbc0c";
          sha256 = "0m3bimpkv0cw4l35mnqzda50yhg8zgikfliq9lmdf36wda00rri7";
        };
      };
    };
    "phpunit/phpunit-mock-objects" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-phpunit-mock-objects-a23b761686d50a560cc56233b9ecf49597cc9118";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/phpunit-mock-objects/zipball/a23b761686d50a560cc56233b9ecf49597cc9118";
          sha256 = "19sa45fzw9fhjdl470i444y64iymhdad7hmlx9q54qjh9y6fy8gk";
        };
      };
    };
    "sebastian/code-unit-reverse-lookup" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-code-unit-reverse-lookup-1de8cd5c010cb153fcd68b8d0f64606f523f7619";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/code-unit-reverse-lookup/zipball/1de8cd5c010cb153fcd68b8d0f64606f523f7619";
          sha256 = "17690sqmhdabhvgalrf2ypbx4nll4g4cwdbi51w5p6w9n8cxch1a";
        };
      };
    };
    "sebastian/comparator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-comparator-2b7424b55f5047b47ac6e5ccb20b2aea4011d9be";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/comparator/zipball/2b7424b55f5047b47ac6e5ccb20b2aea4011d9be";
          sha256 = "0ymarxgnr8b3iy0w18h5z13iiv0ja17vjryryzfcwlqqhlc6w7iq";
        };
      };
    };
    "sebastian/diff" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-diff-7f066a26a962dbe58ddea9f72a4e82874a3975a4";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/diff/zipball/7f066a26a962dbe58ddea9f72a4e82874a3975a4";
          sha256 = "1ppx21vjj79z6d584ryq451k7kvdc511awmqjkj9g4vxj1s1h3j6";
        };
      };
    };
    "sebastian/environment" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-environment-5795ffe5dc5b02460c3e34222fee8cbe245d8fac";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/environment/zipball/5795ffe5dc5b02460c3e34222fee8cbe245d8fac";
          sha256 = "0z1zv8v7k2cycw3vzilpbs7y3mjpwdzcspzgl6pbzi8rj7f4a93l";
        };
      };
    };
    "sebastian/exporter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-exporter-ce474bdd1a34744d7ac5d6aad3a46d48d9bac4c4";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/exporter/zipball/ce474bdd1a34744d7ac5d6aad3a46d48d9bac4c4";
          sha256 = "1g8b7nm7f5dk7rkxhv3l6pclb95az28gi0j5g3inymysa95myh5d";
        };
      };
    };
    "sebastian/global-state" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-global-state-bc37d50fea7d017d3d340f230811c9f1d7280af4";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/global-state/zipball/bc37d50fea7d017d3d340f230811c9f1d7280af4";
          sha256 = "0y1x16mf9q38s7rlc7k2s6sxn2ccxmyk1q5zgh24hr4yp035f0pb";
        };
      };
    };
    "sebastian/object-enumerator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-enumerator-1311872ac850040a79c3c058bea3e22d0f09cbb7";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-enumerator/zipball/1311872ac850040a79c3c058bea3e22d0f09cbb7";
          sha256 = "0f4vdgpq2alsj43bap0sarr79fxnzwpddq96kd18kgfl6n6m730y";
        };
      };
    };
    "sebastian/recursion-context" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-recursion-context-2c3ba150cbec723aa057506e73a8d33bdb286c9a";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/recursion-context/zipball/2c3ba150cbec723aa057506e73a8d33bdb286c9a";
          sha256 = "0rfa6qwayrlzaf4ycwm10m870bmzq152w1rn7wp4vrm283zkf4cs";
        };
      };
    };
    "sebastian/resource-operations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-resource-operations-ce990bb21759f94aeafd30209e8cfcdfa8bc3f52";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/resource-operations/zipball/ce990bb21759f94aeafd30209e8cfcdfa8bc3f52";
          sha256 = "19jfc8xzkyycglrcz85sv3ajmxvxwkw4sid5l4i8g6wmz9npbsxl";
        };
      };
    };
    "sebastian/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-version-99732be0ddb3361e16ad77b68ba41efc8e979019";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/version/zipball/99732be0ddb3361e16ad77b68ba41efc8e979019";
          sha256 = "0wrw5hskz2hg5aph9r1fhnngfrcvhws1pgs0lfrwindy066z6fj7";
        };
      };
    };
    "symfony/yaml" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-yaml-af615970e265543a26ee712c958404eb9b7ac93d";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/yaml/zipball/af615970e265543a26ee712c958404eb9b7ac93d";
          sha256 = "1m1m11s44f0zy100n76pzi23wbwyn7rm2l8rdhnpjp0d8c05i3rj";
        };
      };
    };
    "webmozart/assert" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-assert-bafc69caeb4d49c39fd0779086c03a3738cbb389";
        src = fetchurl {
          url = "https://api.github.com/repos/webmozarts/assert/zipball/bafc69caeb4d49c39fd0779086c03a3738cbb389";
          sha256 = "0wd0si4c9r1256xj76vgk2slxpamd0wzam3dyyz0g8xgyra7201c";
        };
      };
    };
  };
in
composerEnv.buildPackage {
  inherit packages devPackages noDev;
  name = "cydrobolt-polr";
  src = composerEnv.filterSrc ./.;
  executable = false;
  symlinkDependencies = false;
  meta = {
    license = "GPLv2+";
  };
}
