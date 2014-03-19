PUL-Store Deployment Documentation
==================================

Before Everything
-----------------
Set up firewalls to block all ports except 80 to the world and 22 to a select few...

Run Install Scripts
-------------------

### Before
  * Install git (`apt-get install git-core`)
  * Clone the deploy scripts from github

### Run the Scripts
  * From wherever you checked out the scripts, run `sudo ./bootstrap.sh`
  * Get lunch

### After
  * Set up SSH keys
     * Get public keys for each user you want to allow to deploy. Easiest way is from the URI !https://github.com/`<github_user>`.keys
     * Put these keys in `~pul-store/.ssh/authorized_keys`. Make sure the permissions on the the .ssh dir are 0755 or greater, and the authorized_keys file is `0600`.
     * Each user should add an alias for the machine to their `~/.ssh/config` file. Something like this:

        ```
        host pulstore1
            Hostname libserv72.princeton.edu  
            User pul-store  
            Identityfile ~/.ssh/id_dsa  
            ForwardAgent yes
        ```

        The host key (pulstore1 above) value doesn't matter, but it does need to match the argument to `#server` in in the application's config/deploy/production.rb file.

  * Mount Isilon storage at `/opt/fedora/data` - you may need to open a port (e.g. 2049 for NFS, 445 or sim. for Samba, etc.)
  * [PROBABLY MORE BS w/ PERMISSIONS HERE...tomcat7 user needs to be able to write to networked storage]
  * Log out

Deploy PUL-Store
----------------
### Before Capistrano
  Right now each of these files need some kind of configuration or need to be copied to the proper locations
  * database.yml
  * fedora.yml
  * solr.yml
  * pul_store.yml

### Run Capistrano 
From a local copy of the code base (not on the production server, but, say, on your laptop) run:

```
$ bundle exec cap production deploy
```

## After Capistrano
 
 * Link the Solr configuration **(First Time Only)**:

 $ sudo ln -sf /opt/pul-store/current/solr_conf/conf/schema.xml /opt/solr/pul-store/collection1/conf/schema.xml  
 $ sudo ln -sf /opt/pul-store/current/solr_conf/conf/solrconfig.xml /opt/solr/pul-store/collection1/conf/solrconfig.xml
