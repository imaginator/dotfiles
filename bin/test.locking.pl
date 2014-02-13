#!/usr/bin/perl
use Fcntl ':flock'; # import LOCK_* constants
print("Just before opening file.\n");
open(LOCKFILE,">testlockfile") or
die "Error: Could not write to lock file: testlockfile: $!\n";
print("Just before locking file.\n");
flock(LOCKFILE,LOCK_EX);
print("Just before unlocking file.\n");
flock(LOCKFILE,LOCK_UN);
print("All done.  File locked and unlocked.\n");
unlink("testlockfile");
exit(0);
