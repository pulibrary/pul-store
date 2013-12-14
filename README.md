pul-store
=========

[![Build Status](https://travis-ci.org/pulibrary/pul-store.png)](https://travis-ci.org/pulibrary/pul-store.png)

## Install Notes

Includes submodules. To get all of the required code, clone with:

```bash
$ git clone --recursive git@github.com:pulibrary/pul-store.git
```

[Fits](https://github.com/harvard-lts/fits) is also required, but not included with the application. To install it in the correct place run:

```bash
$ rake fits:download
```

The database has a couple of models that needed to be seeded, so in addition to `create`, `migrate`, etc. do

```bash
$ rake db:seed
```

and finally, you need to provide the database password for MySQL. A template is included, so

```bash
$ cp config/database.yml.tmpl database.yml
```

and then add the passwords to `database.yml`.


## About the ActiveFedora Models

At least until things settle down a little, this repo include the [activefedora-models](https://github.com/pulibrary/activefedora-models) as a [git submodule](http://git-scm.com/book/en/Git-Tools-Submodules). Eventually these will become a separate gem, but for now it's nice to have them sitting near to the application's other models. It's a little awkward that tests for the ActiveFedora models live in the pul-store repo, but, again, this can be fixed when we gemify.


## How to Create a Page

right now...

```
stage_path = Page.upload_to_stage(File.new('spec/fixtures/files/00000001.tif'), '00000001.tif')
fits = Page.characterize(stage_path)
p = FactoryGirl.build(:page)
p.master_image = stage_path
p.master_tech_md = fits
p.save
```

## How to instantiate a Title with metadata from Voyager

```
i = Title.new
i.type = "Title"
dmd_src = MetadataSource.where(label: 'Voyager')[0]
i.harvest_external_metadata(dmd_src, '4854502')
i.populate_attributes_from_external_metadata
i.save
```

