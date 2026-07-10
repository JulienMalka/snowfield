{
  addressable = {
    dependencies = [ "public_suffix" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1by7h2lwziiblizpd5yx87jsq8ppdhzvwf08ga34wzqgcv1nmpvz";
      type = "gem";
    };
    version = "2.9.0";
  };
  amazing_print = {
    groups = [ "tools" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sjxbqsngcj6q9bz2r2wpf1k2n73mxb203na4znkg3f7dajandif";
      type = "gem";
    };
    version = "2.0.0";
  };
  ast = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10yknjyn0728gjn6b5syynvrvrwm66bhssbxq8mkhshxghaiailm";
      type = "gem";
    };
    version = "2.4.3";
  };
  bake = {
    dependencies = [
      "bigdecimal"
      "samovar"
    ];
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1izlqnz0828mgdq04s1w291ky912w6jzcg5iwch7gc8l2pkcgylb";
      type = "gem";
    };
    version = "0.24.1";
  };
  base64 = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
    version = "0.3.0";
  };
  bcrypt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0clhya4p8lhjj7hp31inp321wgzb0b5wbwppmya5sw1dikl7400z";
      type = "gem";
    };
    version = "3.1.22";
  };
  better_errors = {
    dependencies = [
      "erubi"
      "rack"
      "rouge"
    ];
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wqazisnn6hn1wsza412xribpw5wzx6b5z5p4mcpfgizr6xg367p";
      type = "gem";
    };
    version = "2.10.1";
  };
  bigdecimal = {
    groups = [
      "default"
      "development"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0612spks81fvpv2zrrv3371lbs6mwd7w6g5zafglyk75ici1x87a";
      type = "gem";
    };
    version = "3.3.1";
  };
  binding_of_caller = {
    dependencies = [ "debug_inspector" ];
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16mjj15ks5ws53v2y31hxcmf46d0qjdvdaadpk7xsij2zymh4a9b";
      type = "gem";
    };
    version = "1.0.1";
  };
  caliber = {
    dependencies = [
      "rubocop"
      "rubocop-capybara"
      "rubocop-disable_syntax"
      "rubocop-packaging"
      "rubocop-performance"
      "rubocop-rake"
      "rubocop-rspec"
      "rubocop-thread_safety"
    ];
    groups = [ "quality" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03lczw6dfafh3zb1qvn6z3y8hng4fywrhxcycgnc3w0k6rqna2l2";
      type = "gem";
    };
    version = "0.91.0";
  };
  capybara = {
    dependencies = [
      "addressable"
      "matrix"
      "mini_mime"
      "nokogiri"
      "rack"
      "rack-test"
      "regexp_parser"
      "xpath"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vxfah83j6zpw3v5hic0j70h519nvmix2hbszmjwm8cfawhagns2";
      type = "gem";
    };
    version = "3.40.0";
  };
  capybara-validate_html5 = {
    dependencies = [
      "capybara"
      "rack-test"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nngj69blr3wmjw7jz7hgx6f4y0lz7xwqmh8ii3ch1cg0p4clnww";
      type = "gem";
    };
    version = "2.1.0";
  };
  childprocess = {
    dependencies = [ "logger" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1v5nalaarxnfdm6rxb7q6fmc6nx097jd630ax6h9ch7xw95li3cs";
      type = "gem";
    };
    version = "5.1.0";
  };
  chunky_png = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1znw5x86hmm9vfhidwdsijz8m38pqgmv98l9ryilvky0aldv7mc9";
      type = "gem";
    };
    version = "1.4.0";
  };
  cogger = {
    dependencies = [
      "core"
      "logger"
      "refinements"
      "tone"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lmp0ws0l44x5p64jvwbyj7k89nc4x04awrwba302c59gby1djyj";
      type = "gem";
    };
    version = "2.2.0";
  };
  concurrent-ruby = {
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aymcakhzl83k77g2f2krz07bg1cbafbcd2ghvwr4lky3rz86mkb";
      type = "gem";
    };
    version = "1.3.6";
  };
  connection_pool = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02ifws3c4x7b54fv17sm4cca18d2pfw1saxpdji2lbd1f6xgbzrk";
      type = "gem";
    };
    version = "3.0.2";
  };
  console = {
    dependencies = [
      "fiber-annotation"
      "fiber-local"
      "json"
    ];
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0dxi072mz8j72r32kkzpky825hn092hb8hdxh4rz3yd5sbv7w6";
      type = "gem";
    };
    version = "1.34.3";
  };
  containable = {
    dependencies = [ "concurrent-ruby" ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rffvxib4ynkax00lh19ih4k6cqv5pv416s2il0kcmmbcnjhx1s7";
      type = "gem";
    };
    version = "2.2.1";
  };
  content_disposition = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05m5ipc81fj2pphlz1ms1yxq80ymilfjhprz790lafjlq6lks5da";
      type = "gem";
    };
    version = "1.0.0";
  };
  core = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0h1lphxfbg9a4w9ahh0vi9aylid57ih1cz75paqa0r8xz7dm3zxk";
      type = "gem";
    };
    version = "3.2.0";
  };
  crass = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  csv = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gz7r2kazwwwyrwi95hbnhy54kwkfac5swh2gy5p5vw36fn38lbf";
      type = "gem";
    };
    version = "3.3.5";
  };
  cuprite = {
    dependencies = [
      "capybara"
      "ferrum"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ay1azfzslgqzxvgxpz9j7i31m0bbpcmrx5wajnrg2yhf3fdah5i";
      type = "gem";
    };
    version = "0.17";
  };
  database_cleaner-core = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0v44bn386ipjjh4m2kl53dal8g4d41xajn2jggnmjbhn6965fil6";
      type = "gem";
    };
    version = "2.0.1";
  };
  database_cleaner-sequel = {
    dependencies = [
      "database_cleaner-core"
      "sequel"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gyl46v7fy9v8vz3vzssalaw46qq2qn7wi2bz5gl5mrl39m5drpi";
      type = "gem";
    };
    version = "2.0.2";
  };
  date = {
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h0db8r2v5llxdbzkzyllkfniqw9gm092qn7cbaib73v9lw0c3bm";
      type = "gem";
    };
    version = "3.5.1";
  };
  debug = {
    dependencies = [
      "irb"
      "reline"
    ];
    groups = [ "tools" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1djjx5332d1hdh9s782dyr0f9d4fr9rllzdcz2k0f8lz2730l2rf";
      type = "gem";
    };
    version = "1.11.1";
  };
  debug_inspector = {
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18k8x9viqlkh7dbmjzh8crbjy8w480arpa766cw1dnn3xcpa1pwv";
      type = "gem";
    };
    version = "1.2.0";
  };
  diff-lcs = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qlrj2qyysc9avzlr4zs1py3x684hqm61n4czrsk1pyllz5x5q4s";
      type = "gem";
    };
    version = "1.6.2";
  };
  docile = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07pj4z3h8wk4fgdn6s62vw1lwvhj0ac0x10vfbdkr9xzk7krn5cn";
      type = "gem";
    };
    version = "1.4.1";
  };
  domain_name = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cyr2xm576gqhqicsyqnhanni47408w2pgvrfi8pd13h2li3nsaz";
      type = "gem";
    };
    version = "0.6.20240107";
  };
  dotenv = {
    groups = [
      "development"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17b1zr9kih0i3wb7h4yq9i8vi6hjfq07857j437a8z7a44qvhxg3";
      type = "gem";
    };
    version = "3.2.0";
  };
  down = {
    dependencies = [
      "addressable"
      "base64"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14xm29krs5mklya6wg0lfvwiccrhi2rnnn82bm13pgwc0zdnvv28";
      type = "gem";
    };
    version = "5.6.0";
  };
  dry-auto_inject = {
    dependencies = [
      "dry-core"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y4gf3ml4d93rpgadx3ywmnn6zr8kql9w57iw4wg2gjss6snq9zr";
      type = "gem";
    };
    version = "1.1.0";
  };
  dry-cli = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x6qlxk6zp3jw748k6x3zkpywx9yjyagdyinb9qai2khdjvmn0dq";
      type = "gem";
    };
    version = "1.4.1";
  };
  dry-configurable = {
    dependencies = [
      "dry-core"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1kkk3fs22ndslgihxwm6rwr0y03rvccljmhz6vpm65q87iginpg3";
      type = "gem";
    };
    version = "1.4.0";
  };
  dry-core = {
    dependencies = [
      "concurrent-ruby"
      "logger"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18cn9s2p7cbgacy0z41h3sf9jvl75vjfmvj774apyffzi3dagi8c";
      type = "gem";
    };
    version = "1.2.0";
  };
  dry-events = {
    dependencies = [
      "concurrent-ruby"
      "dry-core"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pkq9828r9il101ahxw91x0dvc19kqhg7kd65rnc0b7hv9h3kwak";
      type = "gem";
    };
    version = "1.1.0";
  };
  dry-files = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pj1inzqnra6farsc4da0764ymgwpchj72isgwxk13fpg801vsag";
      type = "gem";
    };
    version = "1.1.0";
  };
  dry-inflector = {
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k1dd35sqqqg2abd2g2w78m94pa3mcwvmrsjbkr3hxpn0jxw5c3z";
      type = "gem";
    };
    version = "1.3.1";
  };
  dry-initializer = {
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qy4cv0j0ahabprdbp02nc3r1606jd5dp90lzqg0mp0jz6c9gm9p";
      type = "gem";
    };
    version = "3.2.0";
  };
  dry-logger = {
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1is1bsmbw4yinvd23iqnsqd1njpzi8mv57vpilab4d8i2fy1pyga";
      type = "gem";
    };
    version = "1.2.2";
  };
  dry-logic = {
    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18nf8mbnhgvkw34drj7nmvpx2afmyl2nyzncn3wl3z4h1yyfsvys";
      type = "gem";
    };
    version = "1.6.0";
  };
  dry-monads = {
    dependencies = [
      "concurrent-ruby"
      "dry-core"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ffa0s09czwlmmszwlj1jwh66zlh6frc6kvhc26yhv3wc5vhvjb8";
      type = "gem";
    };
    version = "1.10.0";
  };
  dry-monitor = {
    dependencies = [
      "dry-configurable"
      "dry-core"
      "dry-events"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02d3wzwxa5401h0k24aabaf6kz6jsyb99khbmbhzsjxihlgyvj2a";
      type = "gem";
    };
    version = "1.0.1";
  };
  dry-schema = {
    dependencies = [
      "concurrent-ruby"
      "dry-configurable"
      "dry-core"
      "dry-initializer"
      "dry-logic"
      "dry-types"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09spk1wfpg0v5fi2kblxifjs14pvqka9d452hbn6dbziq2mswfnd";
      type = "gem";
    };
    version = "1.16.0";
  };
  dry-struct = {
    dependencies = [
      "dry-core"
      "dry-types"
      "ice_nine"
      "zeitwerk"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wc07v0qm8zbblr74w3iy2s74sxpifyfpw9b2x01a9259icnhf03";
      type = "gem";
    };
    version = "1.8.1";
  };
  dry-system = {
    dependencies = [
      "dry-auto_inject"
      "dry-configurable"
      "dry-core"
      "dry-inflector"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hyi10vylabjdaj5bj2i40yjcc68mz8fx9wrxb2ckimwik0mfbx0";
      type = "gem";
    };
    version = "1.2.5";
  };
  dry-transformer = {
    dependencies = [
      "bigdecimal"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18sdach3frylc71ffksf2ngrjhhbpad139kndqz9z9laf0mf5gw7";
      type = "gem";
    };
    version = "1.1.0";
  };
  dry-types = {
    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "dry-inflector"
      "dry-logic"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0y7icwaa26ycikz6h97gwd1hji3r280n4yr2kmn5sfgqp76yxsxs";
      type = "gem";
    };
    version = "1.9.1";
  };
  dry-validation = {
    dependencies = [
      "concurrent-ruby"
      "dry-core"
      "dry-initializer"
      "dry-schema"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11c0zx0irrawi028xsljpyw8kwxzqrhf7lv6nnmch4frlashp43h";
      type = "gem";
    };
    version = "1.11.1";
  };
  erb = {
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ncmbdjf2bwmk0jf5cxywns9zbxyfiy4h4p3pzi7yddyjhv81qrq";
      type = "gem";
    };
    version = "6.0.4";
  };
  erubi = {
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1naaxsqkv5b3vklab5sbb9sdpszrjzlfsbqpy7ncbnw510xi10m0";
      type = "gem";
    };
    version = "1.13.1";
  };
  et-orbi = {
    dependencies = [ "tzinfo" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1g785lz4z2k7jrdl7bnnjllzfrwpv9pyki94ngizj8cqfy83qzkc";
      type = "gem";
    };
    version = "1.4.0";
  };
  etcher = {
    dependencies = [
      "cogger"
      "core"
      "dry-monads"
      "dry-types"
      "refinements"
      "versionaire"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1lq42hnr9xdb8bfvjjszxrkngpgyb5irc1ppz8rrcag9rl4ws5d5";
      type = "gem";
    };
    version = "4.2.0";
  };
  faker = {
    dependencies = [ "i18n" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z1yfmqwml3gr1hjnjx6qbchmvr29j6z317wlhkhzabkvw4b6iy1";
      type = "gem";
    };
    version = "3.8.0";
  };
  ferrum = {
    dependencies = [
      "addressable"
      "base64"
      "concurrent-ruby"
      "webrick"
      "websocket-driver"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vp62wy85hr5fa0d29y3wh3zaj10sszj3pl19mps84dja2l4099c";
      type = "gem";
    };
    version = "0.17.2";
  };
  fiber-annotation = {
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00vcmynyvhny8n4p799rrhcx0m033hivy0s1gn30ix8rs7qsvgvs";
      type = "gem";
    };
    version = "0.2.0";
  };
  fiber-local = {
    dependencies = [ "fiber-storage" ];
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
    version = "1.1.0";
  };
  fiber-storage = {
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qa0j9qjwav9xb0n3isx0rbh0942xrfback392n6vs8bidnmp3pl";
      type = "gem";
    };
    version = "1.0.1";
  };
  fugit = {
    dependencies = [
      "et-orbi"
      "raabro"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s5gg88f2d5wpppgrgzfhnyi9y2kzprvhhjfh3q1bd79xmwg962q";
      type = "gem";
    };
    version = "1.12.1";
  };
  functionable = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nk84vb0yl1hdhzkcqnmpqd100j2xdk96gfgyvz1vdlli7cxvsbn";
      type = "gem";
    };
    version = "1.2.0";
  };
  git-lint = {
    dependencies = [
      "cogger"
      "containable"
      "core"
      "dry-monads"
      "dry-schema"
      "etcher"
      "gitt"
      "infusible"
      "refinements"
      "runcom"
      "sod"
      "spek"
      "tone"
      "zeitwerk"
    ];
    groups = [ "quality" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11k1p3lyraaq9lwlz1jh5ix69a0s0drclzz5q5wb8ym1xp30s4sa";
      type = "gem";
    };
    version = "10.2.0";
  };
  gitt = {
    dependencies = [
      "core"
      "dry-monads"
      "refinements"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hqjd8xj53ip1ccrc9nn3jjxsw6p5jwdgq0b5dl3m4h1jsfqmc1y";
      type = "gem";
    };
    version = "5.2.0";
  };
  hanami = {
    dependencies = [
      "dry-configurable"
      "dry-core"
      "dry-inflector"
      "dry-logger"
      "dry-monitor"
      "dry-system"
      "hanami-cli"
      "hanami-utils"
      "json"
      "rack-session"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0frf8lpzb0i2wsc0pr07lmfvv0c2yd15mddw54whrgb0sw87w7ig";
      type = "gem";
    };
    version = "2.3.2";
  };
  hanami-assets = {
    dependencies = [ "zeitwerk" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g92c02hzmfd4xzxndhcwp5azk2f2ncg84x0xl68si9kb1rvp5n3";
      type = "gem";
    };
    version = "2.3.0";
  };
  hanami-cli = {
    dependencies = [
      "dry-cli"
      "dry-files"
      "dry-inflector"
      "irb"
      "rackup"
      "rake"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pphfqg2sy8k1hnz5x0qa0z3rs92bcrsw3l33n130san3qcchgr1";
      type = "gem";
    };
    version = "2.3.5";
  };
  hanami-controller = {
    dependencies = [
      "dry-configurable"
      "dry-core"
      "hanami-utils"
      "rack"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ndrwa4lh4qrapq2ks2yvdka9hdb5zf0sv935hwwhzs39qmxyj5d";
      type = "gem";
    };
    version = "2.3.1";
  };
  hanami-db = {
    dependencies = [
      "rom"
      "rom-sql"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04a7v4h4gf8szf2qfp2iqnw1jbka7rnb5f4r4w9ya8ckdb0sdfnn";
      type = "gem";
    };
    version = "2.3.0";
  };
  hanami-router = {
    dependencies = [
      "csv"
      "mustermann"
      "mustermann-contrib"
      "rack"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07z3i8xjpi7vn0517kw82a3szcncbqvkzsigpl1mgpjip1f6dcw1";
      type = "gem";
    };
    version = "2.3.1";
  };
  hanami-utils = {
    dependencies = [
      "bigdecimal"
      "concurrent-ruby"
      "dry-core"
      "dry-transformer"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "168949pdqn2hf5hbq0a24fgqqd6fpa0rg63xwp5x4jmbfz1zc05a";
      type = "gem";
    };
    version = "2.3.0";
  };
  hanami-validations = {
    dependencies = [ "dry-validation" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ak4vb5kldj04xabzaynxydbdwnf1ja2844p05696wwlhadcviyc";
      type = "gem";
    };
    version = "2.3.0";
  };
  hanami-view = {
    dependencies = [
      "dry-configurable"
      "dry-core"
      "dry-inflector"
      "temple"
      "tilt"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00s6947q8w2kfvraz9rrrrdb6knb0pqlj1d5bcjxp2r18hg5fivh";
      type = "gem";
    };
    version = "2.3.1";
  };
  hanami-webconsole = {
    dependencies = [
      "better_errors"
      "binding_of_caller"
    ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13vn5igki6aclx556rwws62ysqcxgf5cp93np69krawm8ddqxv0g";
      type = "gem";
    };
    version = "2.3.1";
  };
  hansi = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nq59071hmkymrf17fw50by3qplxmzrhxz4hfqx2lsgi57bxy9vy";
      type = "gem";
    };
    version = "0.2.1";
  };
  htmx = {
    dependencies = [
      "refinements"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1gy90q1fqqi45br5h2m2m8cg58b1bc4j4myk8vqpd1fw4223jnsi";
      type = "gem";
    };
    version = "3.2.0";
  };
  http = {
    dependencies = [
      "http-cookie"
      "llhttp"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yhljvkplizid9hqmmqryfd37ybbzld7kijpwnmak708668yf1h2";
      type = "gem";
    };
    version = "6.0.3";
  };
  http-cookie = {
    dependencies = [ "domain_name" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1aga7z4p0dka4zcqw9i05wa4ab1q7h7cgnj328ldqqfycjz84jxs";
      type = "gem";
    };
    version = "1.1.6";
  };
  i18n = {
    dependencies = [ "concurrent-ruby" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1994i044vdmzzkyr76g8rpl1fq1532wf0sb21xg5r1ilj5iphmr8";
      type = "gem";
    };
    version = "1.14.8";
  };
  ice_nine = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nv35qg1rps9fsis28hz2cq2fx1i96795f91q4nmkm934xynll2x";
      type = "gem";
    };
    version = "0.11.2";
  };
  infusible = {
    dependencies = [ "marameters" ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02lw96q23c3mki8jqv6dz3bz0khj54yahacxq33yjzin34rzfzpm";
      type = "gem";
    };
    version = "5.2.0";
  };
  initable = {
    dependencies = [ "marameters" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ffdbcd3zgl4yngqs59w5wm3g1w3ja2nvhsqb55zmyidga2nk73i";
      type = "gem";
    };
    version = "1.2.0";
  };
  inspectable = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "172ssxjhg1pxs0dgpf7xif1ghi688l9nschb9sqwii1pz3qa5vmy";
      type = "gem";
    };
    version = "1.2.0";
  };
  io-console = {
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0lk3pwadm2myvpg893n8jshmrf2sigrd4ki15lymy7gixaxqyn";
      type = "gem";
    };
    version = "0.8.2";
  };
  irb = {
    dependencies = [
      "pp"
      "prism"
      "rdoc"
      "reline"
    ];
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qs8a9vprg7s8krgq4s0pygr91hclqqyz98ik15p0m1sf2h5956y";
      type = "gem";
    };
    version = "1.18.0";
  };
  irb-kit = {
    dependencies = [
      "irb"
      "zeitwerk"
    ];
    groups = [ "tools" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ckhffx8dr48071gllfsbfh9jgix2sm6i2w1q0sw8f9c8krc50da";
      type = "gem";
    };
    version = "2.2.0";
  };
  json = {
    groups = [
      "default"
      "development"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n9ch455pnvl9vxs2f3j77bpdmxg5g3mn3vyr9wxa0a87raii2i1";
      type = "gem";
    };
    version = "2.19.5";
  };
  jwt = {
    dependencies = [ "base64" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mqps8z4ly74hpksfajcfamqk1wb79biy187pn10knmi6zzb26al";
      type = "gem";
    };
    version = "3.2.0";
  };
  language_server-protocol = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1k0311vah76kg5m6zr7wmkwyk5p2f9d9hyckjpn3xgr83ajkj7px";
      type = "gem";
    };
    version = "3.17.0.5";
  };
  launchy = {
    dependencies = [
      "addressable"
      "childprocess"
      "logger"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17h522xhwi5m4n6n9m22kw8z0vy8100sz5f3wbfqj5cnrjslgf3j";
      type = "gem";
    };
    version = "3.1.1";
  };
  lint_roller = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
    version = "1.1.0";
  };
  liquid = {
    dependencies = [
      "bigdecimal"
      "strscan"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wx6lan7kvhxz0i18m1vlnfhmkajxamxjkiyqlhmv4nd60j2qg2s";
      type = "gem";
    };
    version = "5.12.0";
  };
  llhttp = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ih1nljxyfsr8mg6xs56izipkvqh29lhvk0rb536awj0yvn8g8cx";
      type = "gem";
    };
    version = "0.6.1";
  };
  localhost = {
    dependencies = [ "bake" ];
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0097kdsp2fwkps57f8ypc12dqzf4dg4glzn1i32ljjgnnhjshznz";
      type = "gem";
    };
    version = "1.8.0";
  };
  logger = {
    groups = [
      "default"
      "quality"
      "test"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
    version = "1.7.0";
  };
  mapping = {
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18jdbz3x6cvprhsw7jiv44xi6wklric0rq6iznm6xm7c40fr6x12";
      type = "gem";
    };
    version = "1.1.3";
  };
  marameters = {
    dependencies = [
      "refinements"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1069j5q0aaalbdnfjgl0yxx2344w4x5039wamr3p7m46xiycpg6y";
      type = "gem";
    };
    version = "5.2.0";
  };
  marcel = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vhb1sbzlq42k2pzd9v0w5ws4kjx184y8h4d63296bn57jiwzkzx";
      type = "gem";
    };
    version = "1.1.0";
  };
  matrix = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nscas3a4mmrp1rc07cdjlbbpb2rydkindmbj3v3z5y1viyspmd0";
      type = "gem";
    };
    version = "0.4.3";
  };
  mini_magick = {
    dependencies = [ "logger" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1i2ilgjfjqc6sw4cwa4g9w3ngs41yvvazr9y82vapp5sfvymsf99";
      type = "gem";
    };
    version = "5.3.1";
  };
  mini_mime = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vycif7pjzkr29mfk4dlqv3disc5dn0va04lkwajlpr1wkibg0c6";
      type = "gem";
    };
    version = "1.1.5";
  };
  mini_portile2 = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12f2830x7pq3kj0v8nz0zjvaw02sv01bqs1zwdrc04704kwcgmqc";
      type = "gem";
    };
    version = "2.8.9";
  };
  mustermann = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "163i29mdcr1h0nximk3d51a1fgp7vz3sfasn8p1rjm2d4g3p0qac";
      type = "gem";
    };
    version = "3.1.1";
  };
  mustermann-contrib = {
    dependencies = [
      "hansi"
      "mustermann"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07d8hadc7n2phlmc3n3zk42fbpyraxlzl8a7apkj50k6f57z5v63";
      type = "gem";
    };
    version = "3.1.1";
  };
  nio4r = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18fwy5yqnvgixq3cn0h63lm8jaxsjjxkmj8rhiv8wpzv9271d43c";
      type = "gem";
    };
    version = "2.7.5";
  };
  nokogiri = {
    dependencies = [
      "mini_portile2"
      "racc"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s30b7h7qpyim30m8060xs415mbr3ci7i5hdg09chh1aqfx2qcbq";
      type = "gem";
    };
    version = "1.19.3";
  };
  nori = {
    dependencies = [ "bigdecimal" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qb84bbi74q0zgs09sdkq750jf2ri3lblbry0xi4g1ard4rwsrk1";
      type = "gem";
    };
    version = "2.7.1";
  };
  optparse = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "06mx0g76bqwyrv8hxdikhyziyq8x8j8rk9l0y3scyz4hac6s3gj2";
      type = "gem";
    };
    version = "0.8.1";
  };
  parallel = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mlkn1vhh9lr7vljibpgspwsswk7mzm8nw6bbr616c9fbj35hlmk";
      type = "gem";
    };
    version = "2.1.0";
  };
  parser = {
    dependencies = [
      "ast"
      "racc"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m2xqvn1la62hji1mn04y59giikww95p2hs0r4y2rrz3mdxcwyni";
      type = "gem";
    };
    version = "3.3.11.1";
  };
  petail = {
    dependencies = [
      "rack"
      "rexml"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xw5gyi10fbk2hyjx4ic2lb2r9pj2gkhyz6z3y8rklfvw2lmmj5n";
      type = "gem";
    };
    version = "1.2.0";
  };
  pg = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16caca7lcz5pwl82snarqrayjj9j7abmxqw92267blhk7rbd120k";
      type = "gem";
    };
    version = "1.6.3";
  };
  pipeable = {
    dependencies = [
      "containable"
      "dry-monads"
      "marameters"
      "refinements"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j2rvhyv5yfwcdn7qc535bccyyf8a66yk4wfzc4ga78bqdanlqdn";
      type = "gem";
    };
    version = "2.2.0";
  };
  pp = {
    dependencies = [ "prettyprint" ];
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xlxmg86k5kifci1xvlmgw56x88dmqf04zfzn7zcr4qb8ladal99";
      type = "gem";
    };
    version = "0.6.3";
  };
  prettyprint = {
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14zicq3plqi217w6xahv7b8f7aj5kpxv1j1w98344ix9h5ay3j9b";
      type = "gem";
    };
    version = "0.2.0";
  };
  prism = {
    groups = [
      "default"
      "quality"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
    version = "1.9.0";
  };
  psych = {
    dependencies = [
      "date"
      "stringio"
    ];
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x0r3gc66abv8i4dw0x0370b5hrshjfp6kpp7wbp178cy775fypb";
      type = "gem";
    };
    version = "5.3.1";
  };
  public_suffix = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08znfv30pxmdkjyihvbjqbvv874dj3nybmmyscl958dy3f7v12qs";
      type = "gem";
    };
    version = "7.0.5";
  };
  puma = {
    dependencies = [ "nio4r" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z6k79ns8wgz12k3m2r0jc9ddiq6zh8imr4azg0ihmv50w6fb53v";
      type = "gem";
    };
    version = "8.0.1";
  };
  raabro = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10m8bln9d00dwzjil1k42i5r7l82x25ysbi45fwyv4932zsrzynl";
      type = "gem";
    };
    version = "1.4.0";
  };
  racc = {
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
    version = "1.8.1";
  };
  rack = {
    groups = [
      "default"
      "development"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hhjy9gcp52dzij05gmidqac8g28ski5xm67prwmdqmjfcgqxmsy";
      type = "gem";
    };
    version = "3.2.6";
  };
  rack-attack = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wpcxspprm187k6mch9fxhaaq1a3s9bzybd2fdaw1g45pzg9yjgj";
      type = "gem";
    };
    version = "6.8.0";
  };
  rack-session = {
    dependencies = [
      "base64"
      "rack"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1s7zcxlmg88a6dam4aqbgk9xkpy6dkdfqmmcszkkliy3q3w38m2r";
      type = "gem";
    };
    version = "2.1.2";
  };
  rack-test = {
    dependencies = [ "rack" ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qy4ylhcfdn65a5mz2hly7g9vl0g13p5a0rmm6sc0sih5ilkcnh0";
      type = "gem";
    };
    version = "2.2.0";
  };
  rackup = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0s48d2a0z5f0cg4npvzznf933vipi6j7gmk16yc913kpadkw4ybc";
      type = "gem";
    };
    version = "2.3.1";
  };
  rainbow = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  rake = {
    groups = [ "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "009p524zl0p0kfa65nii8wdmaigkmawv9pbvlcffky7islmmp0nb";
      type = "gem";
    };
    version = "13.4.2";
  };
  rbs = {
    dependencies = [
      "logger"
      "prism"
      "tsort"
    ];
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09ggg2zk0qrh0mc3fa23xjbn2gzqxd0jfqj6qm6460ydcqg6fxdg";
      type = "gem";
    };
    version = "4.0.2";
  };
  rdoc = {
    dependencies = [
      "erb"
      "psych"
      "tsort"
    ];
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14iiyb4yi1chdzrynrk74xbhmikml3ixgdayjma3p700singfl46";
      type = "gem";
    };
    version = "7.2.0";
  };
  redcarpet = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iglapqs4av4za9yfaac0lna7s16fq2xn36wpk380m55d8792i6l";
      type = "gem";
    };
    version = "3.6.1";
  };
  redis-client = {
    dependencies = [ "connection_pool" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18xy2nd8mcb186gqd11sy3vfwkq5n85mq26v7l325jkdiwgvyr8c";
      type = "gem";
    };
    version = "0.29.0";
  };
  reek = {
    dependencies = [
      "dry-schema"
      "logger"
      "parser"
      "rainbow"
      "rexml"
    ];
    groups = [ "quality" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qcvqv245bny9kbdn5sajl3sqczy3ai6g048531bpckk4x4klvfj";
      type = "gem";
    };
    version = "6.5.0";
  };
  refinements = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vcpwvkn146hgwl9fb181qj6b812clpawjg2kazrpai85vcl1i73";
      type = "gem";
    };
    version = "14.3.0";
  };
  regexp_parser = {
    groups = [
      "default"
      "quality"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fwfw26a32rps78920nn29shqg2zmqv72i89j1fap41isshida9m";
      type = "gem";
    };
    version = "2.12.0";
  };
  reline = {
    dependencies = [ "io-console" ];
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d8q5c4nh2g9pp758kizh8sfrvngynrjlm0i1zn3cnsnfd4v160i";
      type = "gem";
    };
    version = "0.6.3";
  };
  repl_type_completor = {
    dependencies = [
      "prism"
      "rbs"
    ];
    groups = [ "tools" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dfkxlqyjiv0mdwza1bnbkvw4iil1gigw5cin5akpypyzx2lrhny";
      type = "gem";
    };
    version = "0.1.15";
  };
  rexml = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hninnbvqd2pn40h863lbrn9p11gvdxp928izkag5ysx8b1s5q0r";
      type = "gem";
    };
    version = "3.4.4";
  };
  roda = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xwqr14vxgl04av4rnxhalbw09bnp96gkdjin8vwg6aacfj687hv";
      type = "gem";
    };
    version = "3.104.0";
  };
  rodauth = {
    dependencies = [
      "roda"
      "sequel"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jlq0f9gscc04kvh6mpry856h5a5nrr2yd7b5csh4d81p33gbiad";
      type = "gem";
    };
    version = "2.43.0";
  };
  rom = {
    dependencies = [
      "rom-changeset"
      "rom-core"
      "rom-repository"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j62zsn0lpsf8dc89rq0l615f50gvi6ipfyv3rjkb5kf46x2b2fw";
      type = "gem";
    };
    version = "5.4.3";
  };
  rom-changeset = {
    dependencies = [
      "dry-core"
      "rom-core"
      "transproc"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "165q7phs4nkdqs87zjhb9j6c24kz3i1hv9vdq0l3lx42s0m9sfsh";
      type = "gem";
    };
    version = "5.4.0";
  };
  rom-core = {
    dependencies = [
      "concurrent-ruby"
      "dry-configurable"
      "dry-core"
      "dry-inflector"
      "dry-initializer"
      "dry-struct"
      "dry-types"
      "transproc"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "13zhbmbr47g7856sd1nsn6rly3mk0fcc1xijgsjqdkwj13j690m0";
      type = "gem";
    };
    version = "5.4.0";
  };
  rom-factory = {
    dependencies = [
      "dry-configurable"
      "dry-core"
      "dry-struct"
      "faker"
      "rom-core"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11ggcmxdp39nww3n7zzx4xmv5mhw1mws0l0mmqbq3i52g5gx98xn";
      type = "gem";
    };
    version = "0.13.0";
  };
  rom-repository = {
    dependencies = [
      "dry-core"
      "dry-initializer"
      "rom-core"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mrm066amq3n2ana1xvnwfbjz24qqdby9mf6c69ysh8jw337fm54";
      type = "gem";
    };
    version = "5.4.3";
  };
  rom-sql = {
    dependencies = [
      "dry-core"
      "dry-types"
      "rom"
      "sequel"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fd6cmxcslx93x57z06cdwxyhjnh4rjpn96kbamxfwixc0a0gfjn";
      type = "gem";
    };
    version = "3.7.0";
  };
  rouge = {
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fd77qcz603mli4lyi97cjzkv02hsfk60m495qv5qcn02mkqk9fv";
      type = "gem";
    };
    version = "4.7.0";
  };
  rqrcode = {
    dependencies = [
      "chunky_png"
      "rqrcode_core"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hlm1cfqs891irh4pl6wynsfm7nh7w7baf0g6cqxfrxvlr64khb4";
      type = "gem";
    };
    version = "3.2.0";
  };
  rqrcode_core = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l9hl5nb7jx8sjchsrlv6bk30hywr449ihcdxv2qy6wwz1fvh0zk";
      type = "gem";
    };
    version = "2.1.0";
  };
  rspec = {
    dependencies = [
      "rspec-core"
      "rspec-expectations"
      "rspec-mocks"
    ];
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "11q5hagj6vr694innqj4r45jrm8qcwvkxjnphqgyd66piah88qi0";
      type = "gem";
    };
    version = "3.13.2";
  };
  rspec-core = {
    dependencies = [ "rspec-support" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bcbh9yv6cs6pv299zs4bvalr8yxa51kcdd1pjl60yv625j3r0m8";
      type = "gem";
    };
    version = "3.13.6";
  };
  rspec-expectations = {
    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dl8npj0jfpy31bxi6syc7jymyd861q277sfr6jawq2hv6hx791k";
      type = "gem";
    };
    version = "3.13.5";
  };
  rspec-mocks = {
    dependencies = [
      "diff-lcs"
      "rspec-support"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0iqxmw0knjiz5nf6pgr8ihs6cjzh89f0ppj3fqiz8cvms79x6sh8";
      type = "gem";
    };
    version = "3.13.8";
  };
  rspec-support = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0z64h5rznm2zv21vjdjshz4v0h7bxvg02yc6g7yzxakj11byah06";
      type = "gem";
    };
    version = "3.13.7";
  };
  rubocop = {
    dependencies = [
      "json"
      "language_server-protocol"
      "lint_roller"
      "parallel"
      "parser"
      "rainbow"
      "regexp_parser"
      "rubocop-ast"
      "ruby-progressbar"
      "unicode-display_width"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0pdl45sxbyq7kcg5pxpxpnw23wkqzykg9215ix22r97d6pv9fbmv";
      type = "gem";
    };
    version = "1.86.2";
  };
  rubocop-ast = {
    dependencies = [
      "parser"
      "prism"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dahfpnzz63hyqxa03x8rypnrxzwyvh4i5a8ri34bzpnf3pg64j4";
      type = "gem";
    };
    version = "1.49.1";
  };
  rubocop-capybara = {
    dependencies = [
      "lint_roller"
      "rubocop"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mz3mvjh09awggp0bwsmf4rfaz2irrwc6vzpiklfh7jnlyiipspr";
      type = "gem";
    };
    version = "2.23.0";
  };
  rubocop-disable_syntax = {
    dependencies = [
      "lint_roller"
      "rubocop"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gppdbw0pxl5ygadykr7gi1mknzp0pv6bv4mx5s2zz5kfdbn8q8y";
      type = "gem";
    };
    version = "0.2.0";
  };
  rubocop-packaging = {
    dependencies = [
      "lint_roller"
      "rubocop"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19sqypdixw125l9l0wy8vjbj876m1jdj9lj82vdqqvwfnh7vv4pv";
      type = "gem";
    };
    version = "0.6.0";
  };
  rubocop-performance = {
    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-ast"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d0qyyw1332afi9glwfjkb4bd62gzlibar6j55cghv8rzwvbj6fd";
      type = "gem";
    };
    version = "1.26.1";
  };
  rubocop-rake = {
    dependencies = [
      "lint_roller"
      "rubocop"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0kdfrckz1v32dy7c7bdiksjysx9l9zsda9kc6zvrsghch6vg55rp";
      type = "gem";
    };
    version = "0.7.1";
  };
  rubocop-rspec = {
    dependencies = [
      "lint_roller"
      "rubocop"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qjmvcpk6qwxjdh3w5smr2n7c1glxsdzpv5fi7bkg0j034v0m9wg";
      type = "gem";
    };
    version = "3.9.0";
  };
  rubocop-sequel = {
    dependencies = [
      "lint_roller"
      "rubocop"
    ];
    groups = [ "quality" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04y1yyhrq0fyhrifwbmw9wpkqb5vrzw4n6ml2sk92c8y1i3xq9gk";
      type = "gem";
    };
    version = "0.4.1";
  };
  rubocop-thread_safety = {
    dependencies = [
      "lint_roller"
      "rubocop"
      "rubocop-ast"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cgl90p0bxm1flrxwwagzzm3chhrnm2pwhwmi70zzppmzd9dsz06";
      type = "gem";
    };
    version = "0.7.3";
  };
  ruby-progressbar = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  rubyzip = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0d50hcsix6zrmmijwjx60y4f9n2k0dr6p47cr05qqkrai5kzqwm3";
      type = "gem";
    };
    version = "3.3.0";
  };
  rufus-scheduler = {
    dependencies = [ "fugit" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1f932ffh6v6gqpilm61rp9fcx6qcpax1fkw0ikrxfsgzn16rxyjm";
      type = "gem";
    };
    version = "3.9.2";
  };
  runcom = {
    dependencies = [
      "refinements"
      "xdg"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0scf5p9zj5fj1z2xv8m97jjspdh09bshfcmyzzq2pr400m2gicjy";
      type = "gem";
    };
    version = "13.2.0";
  };
  samovar = {
    dependencies = [
      "console"
      "mapping"
    ];
    groups = [
      "default"
      "development"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "104y60zqn1mznv1smbzzvhljam193w8w2886c2yf6w87b381vff3";
      type = "gem";
    };
    version = "2.4.1";
  };
  sanitize = {
    dependencies = [
      "crass"
      "nokogiri"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "111r4xdcf6ihdnrs6wkfc6nqdzrjq0z69x9sf83r7ri6fffip796";
      type = "gem";
    };
    version = "7.0.0";
  };
  sequel = {
    dependencies = [ "bigdecimal" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0gph3g9nj4cff57z6w925nlgd8wvc0mbp7xj4mf7zah4jadq288m";
      type = "gem";
    };
    version = "5.104.0";
  };
  shrine = {
    dependencies = [
      "content_disposition"
      "down"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "131mfc1mps2aq0ph2zp15hxhsg9lzscys9ik1y85vmjjlkjvfqfk";
      type = "gem";
    };
    version = "3.6.0";
  };
  sidekiq = {
    dependencies = [
      "connection_pool"
      "json"
      "logger"
      "rack"
      "redis-client"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00mb8i0w27pd8vw2wnnbb97shk1h6amvi9bjgwqw400i0gv1z0hr";
      type = "gem";
    };
    version = "8.1.5";
  };
  sidekiq-scheduler = {
    dependencies = [
      "rufus-scheduler"
      "sidekiq"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z6nl9aazi904qmc4vasxkb4w44c6cs1ygfjw6fq8l77i6lz2r8h";
      type = "gem";
    };
    version = "6.0.2";
  };
  simplecov = {
    dependencies = [
      "docile"
      "simplecov-html"
      "simplecov_json_formatter"
    ];
    groups = [ "quality" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
      type = "gem";
    };
    version = "0.22.0";
  };
  simplecov-html = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ikjfwydgs08nm3xzc4cn4b6z6rmcrj2imp84xcnimy2wxa8w2xx";
      type = "gem";
    };
    version = "0.13.2";
  };
  simplecov_json_formatter = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
      type = "gem";
    };
    version = "0.1.4";
  };
  sod = {
    dependencies = [
      "cogger"
      "containable"
      "infusible"
      "optparse"
      "refinements"
      "tone"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zl2f84jv9v4s6kk5i3xc5kib02802qpwc55prpnpjlri7gpnjgg";
      type = "gem";
    };
    version = "2.2.0";
  };
  spek = {
    dependencies = [
      "core"
      "dry-monads"
      "refinements"
      "versionaire"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "175z18fin6w8jx2vi6nhky9zxrp61xijwbb59s316bkvy7p2s2h1";
      type = "gem";
    };
    version = "5.2.0";
  };
  stringio = {
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1q92y9627yisykyscv0bdsrrgyaajc2qr56dwlzx7ysgigjv4z63";
      type = "gem";
    };
    version = "3.2.0";
  };
  strscan = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17k75zrwf4ag9yl9wjjkcb90zrm4r5jigdzv3zr5jm9239hxpqma";
      type = "gem";
    };
    version = "3.1.8";
  };
  temple = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b7pzx45f1vg6f53midy70ndlmb0k4k03zp4nsq8l0q9dx5yk8dp";
      type = "gem";
    };
    version = "0.10.4";
  };
  tilt = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cvaikq1dcbfl008i16c1pi1gmdax7vfkvmhch64jdkakyk9nnqd";
      type = "gem";
    };
    version = "2.7.0";
  };
  tone = {
    dependencies = [
      "refinements"
      "zeitwerk"
    ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01cjm1p1rdcw6vjh69nblv5i3kpmm6aq69gwh16i6ipkzk6fvmgc";
      type = "gem";
    };
    version = "3.2.0";
  };
  transproc = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hn8ypb1y2dxn0igiapm2cxp3zg9kn9arzwk705ly1ppr9gaiydj";
      type = "gem";
    };
    version = "1.1.1";
  };
  trmnl-api = {
    dependencies = [
      "cogger"
      "containable"
      "core"
      "dry-monads"
      "dry-schema"
      "dry-types"
      "http"
      "infusible"
      "inspectable"
      "pipeable"
      "zeitwerk"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "08ik7lk1fc4rq2bnl49p1s4fvssbkanz910j2h1dkwj2ai0magfg";
      type = "gem";
    };
    version = "0.15.0";
  };
  trmnl-liquid = {
    dependencies = [
      "liquid"
      "redcarpet"
      "rqrcode"
      "tzinfo"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02h9wpwmqdsm4qf62n3kjxfqqcq8bmchwwyabvj8i27mjk39kqr5";
      type = "gem";
    };
    version = "0.7.0";
  };
  tsort = {
    groups = [
      "default"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17q8h020dw73wjmql50lqw5ddsngg67jfw8ncjv476l5ys9sfl4n";
      type = "gem";
    };
    version = "0.2.0";
  };
  tzinfo = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
    version = "2.0.6";
  };
  unicode-display_width = {
    dependencies = [ "unicode-emoji" ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hiwhnqpq271xqari6mg996fgjps42sffm9cpk6ljn8sd2srdp8c";
      type = "gem";
    };
    version = "3.2.0";
  };
  unicode-emoji = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03zqn207zypycbz5m9mn7ym763wgpk7hcqbkpx02wrbm1wank7ji";
      type = "gem";
    };
    version = "4.2.0";
  };
  versionaire = {
    dependencies = [ "refinements" ];
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j0dq63b0q65f5al54bmmvv85gnwnspxzbd5rw5npnc11wlybqh5";
      type = "gem";
    };
    version = "15.2.0";
  };
  warning = {
    groups = [ "test" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "17kcvdmz9flxqzi4qkjvsaf9wxdbz12vxvzjzydd2xzv36pdz754";
      type = "gem";
    };
    version = "1.6.0";
  };
  webrick = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0ca1hr2rxrfw7s613rp4r4bxb454i3ylzniv9b9gxpklqigs3d5y";
      type = "gem";
    };
    version = "1.9.2";
  };
  websocket-driver = {
    dependencies = [
      "base64"
      "websocket-extensions"
    ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0qj9dmkmgahmadgh88kydb7cv15w13l1fj3kk9zz28iwji5vl3gd";
      type = "gem";
    };
    version = "0.8.0";
  };
  websocket-extensions = {
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
    version = "0.1.5";
  };
  wholeable = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "184vd03lgzyf2jvc69hr8ri7qzc7w00lnmm2x1ww70p49w3wsw9p";
      type = "gem";
    };
    version = "2.2.0";
  };
  xdg = {
    groups = [
      "default"
      "quality"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0a7hdb2nhkb9z675j1m9h9qy0jpm97ymyfdhll2znj4mw91naxgy";
      type = "gem";
    };
    version = "10.2.0";
  };
  xpath = {
    dependencies = [ "nokogiri" ];
    groups = [
      "default"
      "test"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      type = "gem";
    };
    version = "3.2.0";
  };
  zeitwerk = {
    groups = [
      "default"
      "quality"
      "test"
      "tools"
    ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0g9y9xms54wbhlapaz06hv1czl70pkfzax25gjpkbxi94hfhlka7";
      type = "gem";
    };
    version = "2.8.0";
  };
}
