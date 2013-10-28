pul-store
=========

**Note**: includes submodules. To get all of the required code, clone with:

```bash
$ git clone --recursive git@github.com:pulibrary/pul-store.git
```
You must establish a connection to github [using SSH keys](https://help.github.com/articles/generating-ssh-keys) rather than HTTPS for this to work.

## About the ActiveFedora Models

At least until things settle down a little, this repo include the [activefedora-models](https://github.com/pulibrary/activefedora-models) as a [git submodule](http://git-scm.com/book/en/Git-Tools-Submodules). Eventually these will become a separate gem, but for now it's nice to have them sitting near to the application's other models.

For now it's a little awkward that tests for activefedora models live in the pul-store repo, but, again, this can be fixed with we gemify.


[![Build Status](https://travis-ci.org/pulibrary/pul-store.png)](https://travis-ci.org/pulibrary/pul-store.png)
