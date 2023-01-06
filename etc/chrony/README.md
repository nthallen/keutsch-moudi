# chronyd configuration
We used chronyd for time synchronization during DCOTSS on the ER-2.
By default, Raspbian uses systemd-timesyncd. We can try using that
on the WB-57 unless it proves to be problematic. The configuration
here in chrony.conf is the one used on the ER-2. The only change
required would be to update the NTP server IP address. It would
also be necessary to install chronyd, disable systemd-timesyncd
and enable chronyd.
