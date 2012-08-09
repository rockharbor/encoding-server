# Media Encoding Server

These scripts are used in conjunction with [watchdog][1] and [Adobe Media Encoder][2] to
create an automated media encoding server.

## Installation

1. Install [watchdog][1] and [Adobe Media Encoder][2]

2. Create a `wordpress.conf` file with the WordPress credentials (Please note the syntax -
   no spaces and your user and password wrapped in double quotes.):

    ```
    WP_USER="wordpress_user"
    WP_PASSWORD="wordpress_password"
    ```

3. Ensure that Adobe Media Encoder is running and watching the correct folders.

4. From the terminal in the directory these scripts are located, run `encoding-server`

## Workflow

Below is an explaination of the watch/encode/upload process.

1. The scripts start watching the FTP folders
2. When a file is detected, it is watched until it is fully uploaded
3. After it is completely uploaded, it is renamed and moved into a "to compress" staging
folder
4. Adobe Media Encoder watches the "to compress" folders and will encode and create
compressed items in a new folder
5. That folder is being watched by the scripts, which inturn uploads the file to 
WordPress

## Plans

It would be cool to be able to ditch Adobe Media Encoder in favor of [ffmpeg][3]. First,
it would reduce the complexity of the watch-and-wait methods used here. It would also
eliminate the need for a UI as well as the dependency of OSX (needed for running Adobe
Media Encoder).

[1]: https://github.com/gorakhargosh/watchdog
[2]: http://www.adobe.com/products/mediaencoder.html
[3]: http://ffmpeg.org/
