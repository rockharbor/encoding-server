# Media Encoding Server

These scripts are used in conjunction with [watchdog][1] and [ffmpeg][2] to
create an automated media encoding server.

## Installation

1. Install [watchdog][1] and [ffmpeg][2]

2. Create a `credentials.conf` file with the WordPress and Network storage credentials (Please note the syntax -
   no spaces and your user and password wrapped in double quotes.):

    ```
    WP_USER="wordpress_user"
    WP_PASSWORD="wordpress_password"
    ```

3. Copy the `plist` file to `/System/Library/LaunchDaemons` and give it the proper permissions: 644 / root:wheel. This allows the watch processes to be run automatically.
4. From the terminal in the directory these scripts are located, run `encoding-server`, or reboot

## Directory structure

The watch directories are hardcoded into the `encoding-server` script. The basic structure
looks like this:

    ```
    /FTP
      /<campus_short_name>
    ```

Where `<campus_short_name>` is RHO, RHMV, etc. Once received, they are stored in an Output and Source folder within the campus short name folder within the `STOREPATH` directory, as defined in the `encoding-server` script.

## Workflow

Below is an explaination of the watch/encode/upload process.

1. The scripts start watching the FTP folders
2. After the file is uploaded, the FTP server renames it, which triggers the watch
3. The process scripts are then triggered and find the most recent file
4. The file is then converted using ffmpeg into a
   streaming video file as well as an mp3.
5. When the encoding process completes, the source moved 
   into the `Source` folder, and the converted files are moved into the
   `Output` folder. These folders are explained in the Directory Structure section.
6. Finally, the two output files are uploaded to WordPress

## Plans

1. Remove all hardcoded stuff, like paths to network drives
2. Create a start/stop action: `encoding-server start`

[1]: https://github.com/gorakhargosh/watchdog
[2]: http://ffmpeg.org/
