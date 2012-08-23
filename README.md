# Media Encoding Server

These scripts are used in conjunction with [watchdog][1] and [ffmpeg][2] to
create an automated media encoding server.

## Installation

1. Install [watchdog][1] and [ffmpeg][2]

2. Create a `wordpress.conf` file with the WordPress credentials (Please note the syntax -
   no spaces and your user and password wrapped in double quotes.):

    ```
    WP_USER="wordpress_user"
    WP_PASSWORD="wordpress_password"
    ```

3. From the terminal in the directory these scripts are located, run `encoding-server`

## Directory structure

The watch directories are hardcoded into the `encoding-server` script. The basic structure
looks like this:

    ```
    /Volumes
      /Media
        /FTP
          /Messages
            /<campus_short_name>
              /Output
              /Source
    ```

Where `<campus_short_name>` is RHO, RHMV, etc. 

## Workflow

Below is an explaination of the watch/encode/upload process.

1. The scripts start watching the FTP folders
2. When a file is detected, it is watched until it is fully uploaded
3. After the upload completes, the file is converted using ffmpeg into a
   streaming video file as well as an mp3.
4. When the encoding process completes, the source is renamed and moved 
   into the `Source` folder, and the converted files are moved into the
   `Output` folder.
5. Finally, the two output files are uploaded to WordPress

## Plans

1. Remove all hardcoded stuff
2. Create a start/stop action: `encoding-server start`

[1]: https://github.com/gorakhargosh/watchdog
[2]: http://ffmpeg.org/
