## Usage

Implementing a Zero-Downtime deployment in forge is pretty simple, just follow these steps:

````Note: The first release will introduce some downtime as some setup is needed. Make sure to put your website into maintaince mode first.```

1. Manually run the commands in the `setup.sh` script. This will delete all your project files except for your `storge folder` and `.env file`, which are the only two elements that should persist in your server throught deployments (the rest of the files and directories will be downloaded for every deployment).
2. Add the contents of `deploy.sh` to your forge deployment script, and make sure you **fill out the variables in the Config section** with your own values.
3. Deploy your project.
4. Go to your forge site and click on the site's `META`. In the Web Directory, replace where it says `/public` with `/current/public` and hit `Update Web Directory`
5. Visit your website. Everything should be working now, and any future deploy won't give you any downtime.