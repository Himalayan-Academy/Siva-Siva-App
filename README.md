# Siva-Siva-App
Code Repository for the Siva Siva Mobile App

## File Structure
The code lives inside the ```source``` folder. A ```shared``` folder hosts both ```libraries``` and shared ```assets```. Modules live in their own folder inside the ```modules``` folder.

### Configuration for the app (config.json)
This JSON file holds the configuration for the app itself. Individual modules may host their own configuration JSON as well.

The most important items in this file are:

* The autoload array which lists which libraries to load at the start of the app.
* The launch module item which specifies which module should be considered the home module.

## API
The loader stack provides a **backscript for the API to be shared between modules**, this exists inside a button called **API backscript**. Libraries also share their code on the message path for other modules to use but the core routines are a part of this backscript.




# Working Back Ups
  add this to the preopenstack handler of any module: 
backupStack  to create incremental backups of your work stack every 15 minutes. be sure .gitignore includes ".bac"
