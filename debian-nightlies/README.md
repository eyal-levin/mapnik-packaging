Scripts to build Debian nightlies of mapnik branches, and upload to PPAs.

They currently run on Koordinates' CI server every night at 0000UTC and upload 
to the Mapnik nightly build PPAs at https://launchpad.net/~mapnik

If you want to use the packages created from these scripts add this PPA:

https://launchpad.net/~mapnik/


Requirements:

* apt-get install debhelper devscripts python-scons dput git-core python


Setting up:

1) Clone the packaging repo and enter debian dir:

    git clone git://github.com/mapnik/mapnik-packaging.git
    cd mapnik-packaging/debian-nightlies

2) Clone the mapnik git repo from https://github.com/mapnik/mapnik into a git/ dir:

    git clone https://github.com/mapnik/mapnik git

3) Update the nightly-build.sh script with your name/GPG key/etc, and 
what branches/dists/ppas you want. Set the latest releases correctly too.


4) Set prev.rev in each branch directory to be the current revision of the branch

    cd git
    git log -1 --pretty=format:%h > ../master/pre.rev
    cd ../
    
5) Run ./nightly-builds.sh -f -d to make sure it works (you should see usage)

6) Run ./nightly-builds.sh -f to force the first build & upload

7) Run ./nightly-builds.sh -c to delete what you just built

8) After that, run ./nightly-builds.sh and it'll regenerate and upload source packages if something's changed.

9) Run ./nightly-builds.sh -c to cleanup occasionally

10) Re-run a single trunk build because you've fixed debian/ stuff, do
   
    ./nightly-builds.sh -f -b trunk -r 2


Notes:

debian/ directories are taken from the appropriate directory for each branch, 
except for the changelog which is built dynamically.


License: 

* GPL-2+

Feedback:

* Robert Coup <robert@coup.net.nz>
* Dane Springmeyer <dane@dbsgeo.com>
