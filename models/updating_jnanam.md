# Updating jnanam.sqlite

Issue: https://github.com/Himalayan-Academy/Siva-Siva-App/issues/107

To generate a new `jnanam.sqlite.gz`:

1. Log into ssh on devhap.
2. inside `public_html/andre` there is a `dump_jnanam.sh` script.
3. Run `./dump_jnanam.sh`.
4. A new `jnanam.sqlite.gz` file will be placed in this folder. Download it to `models/jnamam/`.
