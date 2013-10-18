pul-store
=========

**Note**: includes submodules. To get all of the required code, clone with:

```bash
$ git clone --recursive git@github.com:pulibrary/pul-store.git
```

## About the ActiveFedora Models

At least until things settle down a little, this repo include the [activefedora-models](https://github.com/pulibrary/activefedora-models) as a [git submodule](http://git-scm.com/book/en/Git-Tools-Submodules). Eventually these will become a separate gem, but for now it's nice to have them sitting near to the application's other models.

The activefedora-models tests live in `app/models/afmodels/spec` and so the command to run all tests is:

```bash
$ rspec spec app/models/afmodels/spec
```
