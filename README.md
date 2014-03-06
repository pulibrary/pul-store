pul-store
=========

[![Build Status](https://travis-ci.org/pulibrary/pul-store.png?branch=development)](https://travis-ci.org/pulibrary/pul-store)

[Fits](https://github.com/harvard-lts/fits) is also required, but not included with the application. To install it into your development environment, run:

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


## Other Stuff



### How to Create a Page

right now...

```
stage_path = Page.upload_to_stage(File.new('spec/fixtures/files/00000001.tif'), '00000001.tif')
fits = Page.characterize(stage_path)
p = FactoryGirl.build(:page)
p.master_image = stage_path
p.master_tech_md = fits
p.save
```

### How to instantiate a Text with metadata from Voyager

```
t = Text.new
dmd_src = MetadataSource.where(label: 'Voyager')[0]
t.harvest_external_metadata(dmd_src, '4854502')
t.populate_attributes_from_external_metadata
t.save
```

### How to seed your environment with LAE objects.
```
rake lae:seed_dev
```
