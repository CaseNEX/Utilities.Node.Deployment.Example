// https://github.com/Unitech/PM2/blob/master/ADVANCED_README.md#list-of-all-json-declaration-fields-avaibles
{
	"apps": [{
		"name": "HelloWorld",
		"script": "/home/www/node/HelloWorld/index.js",
		"args": [],
		"instances": -1, //1 less than total cores
		"watch": false,
		"node_args": "--harmony",
		"merge_logs": true,
		"cwd": "/home/www/node/HelloWorld",
		"exec_mode": "cluster_mode",
		"log_date_format": "YYYY-MM-DD HH:mm Z",
		"error_file": "/home/www/logs/HelloWorld/err.log",
		"out_file": "/home/www/logs/HelloWorld/out.log",
		"pid_file": "/home/www/logs/HelloWorld/child.pid",
		"next_gen_js": true,
		"env": {
			"NODE_ENV": "dev"
		}
	}]
}