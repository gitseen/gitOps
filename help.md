# [cht.sh](https://github.com/chubin/cheat.sh)

# Usage
To get a cheat sheet for a UNIX/Linux command from a command line, query the service using curl or any other HTTP/HTTPS client specifying the name of the command in the query:  
    ```
    curl cht.sh
    curl cheat.sh/tar
    curl cht.sh/curl
    curl https://cheat.sh/rsync
    curl https://cht.sh/tr
    ```

The programming language cheat sheets are located in special namespaces dedicated to them.  
    ```
    curl cht.sh/go/Pointers
    curl cht.sh/scala/Functions
    curl cht.sh/python/lambda
    ```
To get the list of available programming language cheat sheets, use the special query :list:  
    ```
    curl cht.sh/go/:list
    ```


