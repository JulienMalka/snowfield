require ["variables", "fileinto", "envelope", "subaddress", "mailbox"];

# rule:[FRnOG]
if allof (header :contains "subject" "[FRnOG]")
{
	fileinto "INBOX.frnog";
	stop;
}
# rule:[dn42]
if allof (header :contains "subject" "[dn42]")
{
	fileinto "INBOX.dn42";
	stop;
}
# rule:[Lobsters]
if allof (header :is "to" "lobsters-hQ3nfqM88Q@lobste.rs")
{
	fileinto "INBOX.lobsters";
	stop;
}
# rule:[Fosdem]
if allof (header :contains "subject" "[devroom-managers]")
{
	fileinto "INBOX.fosdem";
	stop;
}
# rule:[Promox]
if allof (header :contains "subject" "[pve-devel]")
{
	fileinto "INBOX.proxmox";
	stop;
}
# rule:[Github]
if allof (header :contains "from" "notifications@github.com")
{
	fileinto "INBOX.github";
	stop;
}
# rule:[Netdata]
if allof (header :contains "from" "netdata")
{
	fileinto "INBOX.netdata";
	stop;
}
#rule:[Lol]
if header :matches "X-Original-To" "*@malka.sh" {
    set :lower "name" "${1}";
    if string :is "${name}" "" {
    	fileinto "INBOX";
    } 
    elsif string :is "${name}" "julien" {
	fileinto "INBOX";
    } else {
    	fileinto :create "INBOX.${name}";
    }
}
