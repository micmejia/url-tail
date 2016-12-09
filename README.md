
url-tail
=========

  This bash script monitors url for changes and print its tail into standard output. It acts as "tail -f" linux command.
  It can be helpful for tailing logs that are accessible by http.

# Installation

## Linux

  Script needs `curl` to be installed. Many Linux distributions as well as Mac OS X already have curl installed.

  Just download `url-tail.sh`, chmod, then use it.

    sudo curl -o /usr/bin/url-tail -s https://raw.githubusercontent.com/micmejia/url-tail/master/script/src/url-tail.sh
    sudo chmod +x /usr/bin/url-tail

## Windows

This assumes you have `curl.exe` and `bash.exe` installed in your machine.

Just download `url-tail.sh` and `url-tail.bat`, and save it to one of the directory under your `PATH` environment variable.

# Usage

    Syntax: url-tail <URL> [<starting_tail_offset_in_bytes> | -1] [<update_interval_in_secs>] [<curl_options>...]

  To start tailing url just run:

    url-tail http://example.com/file_to_tail

  Script will stop automatically if remote file will be re-created e.g. in case of log rotation.

  If you want to start url-tail with some data displayed you can tell it how many bytes to fetch from the end of file:

    url-tail http://example.com/file_to_tail 1000

  Or initially fetch all the file's data:

    url-tail http://example.com/file_to_tail -1

Default `update_interval_in_secs` is 3 seconds.
All remaining command arguments `<curl_options>` will be passed to curl.

  Full example: tail the file with 0 bytes initially, update every 10 seconds, and specify server user and password:

    url-tail http://example.com/file_to_tail 0 10 -uusername:password
