# Managing Remote Machines

## Task

Install `cowsay` on your machine and create a cowsay.txt in `/var/www/html` with the output of cowsay as shown below.

```
$ cowsay unix is awesome
 _________________
< unix is awesome >
 -----------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Solution:

First we need to install cowsay.

```
$ sudo apt install cowsay
...
```

Lets run it and see.

```
$ cowsay unix is awesome
 _________________
< unix is awesome >
 -----------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

It is working. Now lets' go and add a file in /var/www/html.

```
$ sudo bash
# cowsay hello
Command 'cowsay' is available in '/usr/games/cowsay'
The command could not be located because '/usr/games' is not included in the PATH environment variable.
cowsay: command not found
```

It is not working because cowsay in not in the path.

```
$ which cowsay
/usr/games/cowsay

$ sudo bash
# /usr/bin/cowsay hello
 _______
< hello >
 -------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

We made it work now.

## Using `tmux`

### Working with sessions

Create a new tmux session using:

```
$ tmux
```

You can also give a name to your session by running:

```
$ tmux new -s name-of-session
```

You can detach from an existing tmux session by pressing:

```
Ctrl+b d
```

You can list all the existing sessons using:

```
$ tmux ls
```

Attach to the last session using:

```
$ tmux a
```

You can also attach to a sesson by specify the name of the session (show in the output of `tmux ls`).

```
$ tmux a -t session-name
```

You can cycle between existing sessions using the following keys:

```
Ctrl+b (
Ctrl+b )
```

### Working with windows

Each tmux session can have multiple windows.

Create a new window using:

```
Ctrl+b c
```

Select a window using:

```
Ctrl+b 0
Ctrl+b 1
...
```

Cycle between windows using:

```
Ctrl+b n
Ctrl+b p
```

Refer to [tmuxcheatsheet.com](https://tmuxcheatsheet.com/) for more information.

## Setting up a new website

Let's setup a new website `figlet.alpha.k8x.in`, showing a messge using figlet.

Step 1: create a directory with the contents of the website.

```
$ cd /var/www
$ sudo bash
# mkdir figlet
# echo '<pre>' > index.html
# figlet hello >> index.html
# echo '</pre>' >> index.html
```

Step 2: Create nginx configuration for the new site

```
$ cd /etc/nginx/sites-enabled/
$ sudo nano figlet

server {
    listen 80;
    server_name figlet.alpha.k8x.in;
    root /var/www/figlet;
}
```

Step 3: restart nginx

```
$ sudo /etc/init.d/nginx restart
```

The nginx server can also be restarted using `sudo service nginx restart`.

Now you can visit <https://figlet.alpha.k8x.in/>.

## Deploying a python webapp

Let's see what does it take to deploy a Python webapp.

We'll deploy a simple webapp `figlet-web`.

Create a new tmux window for setting up the app.

We'll be using the [figlet-web](https://github.com/anandology/figlet-web) app for this.

Start with cloning the repository in your home directory.

```
$ git clone https://github.com/anandology/figlet-web.git
...
$ cd figlet-web
```

Create a virtual env. You may have to install the apt package `python3-venv`, if it is not already installed.

```
$ python3 -m venv venv
...
$ source venv/bin/activate
```

Install the dependencies.

```
$ pip install -r requirements.txt
```

Run the webapp.

```
$ gunicorn -b 0.0.0.0:8000 webapp:app
```

Now your site will be accessible at `http://alpha.k8x.in:8000/`.

### Setting up nginx reverse proxy

However, it is a good idea to expose guncorn webserver to the outside world directly. It is a good practice to put it behind nginx.

```
Gunicorn <--> Nginx <--> Internet
```

Lets setup `figlet-web.alpha.k8x.in`.

Keep the window with python webapp continue running and open a new window to setup nginx.

Create a new config file `figlet-web` in `/etc/nginx/sites-enabled/` with the following contents.

```
$ cd /etc/nginx/sites-enabled
$ sudo nano figlet-web
server {
    listen 80;
    server_name figlet-web.alpha.k8x.in;
    root /var/www/figlet-web;

    location / {
        proxy_pass http://localhost:8000/;
    }
}
```

The `proxy_pass` directive passes all the requests to the gunicorn service.

## Setting up HTTPS

Lets install certbot to get https certificates.

```
$ sudo snap install core; sudo snap refresh core
$ sudo snap install --classic certbot
```

Now it is time to get https certificates from certbox.

```
$ sudo certbot --nginx
```

And follow the instructions!

## Running the python webapp as system service

So far, we have run the python webapp in our tmux session. Let's make that into a system service.

Let's use supervisor for running it.

```
$ sudo apt install supervisor
```

And add the following configuration in `figlet-web.conf`.

```
$ sudo nano /etc/supervisor/conf.d/figlet-web.conf
[program:figlet-web]
command=/home/k8x/figlet-web/venv/bin/gunicorn -b 127.0.0.1:8000 webapp:app
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/figlet-web.log
redirect_stderr=true
user=k8x
directory=/home/k8x/figlet-web
```

Now we need to reload the supervisor.

```
$ sudo supervisorctl reread
$ sudo supervisorctl update
```

That would start the figlet-web process. You can verify it using:

```
$ sudo supervisorctl status
```

If you ever want to restart your app, you can do using:

```
$ sudo supervisor restart figlet-web
```

The supervisor will monitor the application and restart it if it does down. You can verify that by running:

```
$ ps -u k8x | grep gunicorn
   1125 ?        00:00:00 gunicorn
   1359 ?        00:00:00 gunicorn

$ killall gunicorn

$ ps -u k8x | grep gunicorn
   2102 ?        00:00:00 gunicorn
   2104 ?        00:00:00 gunicorn
```

In the above example, we've killed all the gunicorn processes and supervisor restarted them automatically.

## Task 1 - Deploy the railways data as datasette website

[Datasette](https://datasette.io) is a tool for exploring and publishing data.

Use the datasette to publish the indian railways data as a website.

Steps:

1. clone the repo <https://github.com/anandology/railways>
2. create a sqlite3 database using the followig commands:

        $ sqlite3 railways.db < schema.sql
        $ sqlite3 railways.db < import.sql

    You may have to install `sqlite3` package.

3. Install datasette using `pip`. You may want to create a virtualenv before doing this.

        $ pip install datasette

4. Serve the dataset using datasette

        $ datasette serve railways.db

    Run `datasette --help` to see different options of datasette.


Your task is to setup website <https://railways.alpha.k8x.in>. This includes:

- running datasette using supervisor
- setting up SSL certificate using certbot
