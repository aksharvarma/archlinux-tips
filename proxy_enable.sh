#!/bin/bash

export http_proxy=http://192.168.32.3:8080/
export http_proxy=''
export https_proxy=$http_proxy
export ftp_proxy=$http_proxy
export rsync_proxy=$http_proxy
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
