#!/bin/bash
#################################################################################
# Ident         : mean-init.sh - 1.3
# Auteur        : J.Behuet
#
# Description   : Automatisation de la création de la base d'un projet JS
#
# Usage         : ./mean-init.sh
# Remarque(s)   : Ce script nécessite NodeJS
#
# Versions      :
#  V   | Date     | Auteur           | Description des modifications
# -----|----------|------------------|------------------------------------------
# 1.0  |05-10-2015| J.Behuet         | Initial
# 1.1  |08-10-2015| J.Behuet         | CRUD
# 1.2  |08-10-2015| J.Behuet         | Fix errors
# 1.3  |12-03-2016| J.Behuet         | Change ORM
# 1.4  |18-03-2016| JB.Pasquier      | Add bower for dependencies + node >5 install + npm update + routes.js + confirm folder name
#
#################################################################################

NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
CYAN="\\033[1;36m"
VERT="\\033[1;32m"
echo -e "$VERT" "MEAN-INIT setup" "$NORMAL"
read -r -p "What's your project name? " response
clear
pwd=`pwd`
echo "  This will install all of the MEAN stack on the folder $pwd/$response"
read -r -p "Press enter to continue... " confirm
clear
if [ -z "$response" ]; then
    echo 'Exiting...'
else
    if [ -z "$confirm" ]; then
        read -r -p "[UBUNTU ONLY] Press enter if you want to update node and npm or type 'no' then enter " upd
        if [ -z "$upd" ]; then
            echo 'Updating...'
            curl -sL https://deb.nodesource.com/setup_5.x | sudo bash -
            sudo apt-get install nodejs
            sudo npm install -g n
            sudo n latest
        else
            echo 'Ok!'
        fi
        echo "Creating directories..."
        mkdir $response
        cd $response
        mkdir app
        mkdir public
        mkdir config
        mkdir app/models
        mkdir app/routes
        mkdir public/views
        mkdir public/css
        mkdir public/fonts
        mkdir public/js
        mkdir public/js/controllers
        mkdir public/js/services
        mkdir public/js/libs
        echo "Creating some files..."
        echo "
        var mongoose = require('mongoose');
        module.exports = mongoose.connect('mongodb://localhost/$response');
        " > ./config/database.js.sample
        echo "/* AUTHOR CUSTOM STYLE SHEET */
body{
    padding-top: 70px;
}
.navbar-border{
    border-bottom: 3px solid #F0DB4F;
}
.navbar-header img{
    transition: 0.4s;
}
.navbar-header img:hover{
    transform: rotate(360deg);
}  " > public/css/style.css
        # Create gitignore
        echo 'node_modules/
*.DS_Store
config/database.js
npm-debug.log
public/bower' > .gitignore

        # Create index.html
        echo "<!DOCTYPE html>
    <html ng-app="app">
        <head>
            <meta charset='utf-8' />
            <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no' />
            <meta http-equiv='X-UA-Compatible' content='IE=edge'>
            <meta name='description' content='' />
            <meta name='author' content='' />
            <title>$response</title>
            <link rel='stylesheet' href='css/bootstrap.min.css' />
            <link rel='stylesheet' href='css/bootstrap-theme.min.css' />
            <link rel='stylesheet' href='css/style.css' />
        </head>
        <body>
            <nav class='navbar navbar-inverse navbar-fixed-top navbar-border' role='navigation'>
                <div class='container'>
                    <div class='navbar-header'>
                        <a href='#/'><img src='http://unhosted.org/slides/img/js.png' width='50px'></a>
                    </div>
                    <ul class='nav navbar-nav'>
                        <li ng-class='{active: activetab==\"/\"}'><a href='#/'>Home</a></li>
                        <li ng-class='{active: activetab==\"/about\"}'><a href='#/about'>About</a></li>
                    </ul>
                </div>
            </nav>
            <div class='container'>
                <ng-view></ng-view>
            </div>
            <script src='js/libs/jquery.min.js'></script>
            <script src='js/libs/bootstrap.min.js'></script>
            <script src='js/libs/angular.min.js'></script>
            <script src='js/libs/angular-animate.min.js'></script>
            <script src='js/libs/angular-route.min.js'></script>
            <script src='js/controllers/mainController.js'></script>
            <script src='js/services/todosService.js'></script>
            <script src='js/routes.js'></script>
            <script src='js/app.js'></script>
        </body>
    </html>" > public/index.html


        # Create todoService.js
        echo "// TODO SERVICE
    function todoService(\$http) {
        return {
            get : function() {
                return \$http.get('/todos');
            },
            update : function(id, data){
                return \$http.put('/todos/' + id, data);
            },
            create : function(data) {
                return \$http.post('/todos', data);
            },
            delete : function(id) {
                return \$http.delete('/todos/' + id);
            }
        }
    };" > public/js/services/todoService.js

        # Create routes.js
        echo "function routes(\$routeProvider) {
        \$routeProvider
            .when('/', {
                templateUrl: 'views/main.html',
                controller: 'mainController'
            })
            .when('/about', {
                templateUrl: 'views/about.html'
            })
            .otherwise({
                redirectTo: '/'
            });
    }
    " > public/js/routes.js

        # Create app.js
        echo "
    function run(\$rootScope, \$location){
        var path = function() { return \$location.path(); };
        \$rootScope.\$watch(path, function(newVal, oldVal){
            \$rootScope.activetab = newVal;
        });
    }
    angular.module('app', ['ngRoute','ngAnimate'])
        .config(routes)
        .controller('mainController', mainController)
        .service('todoService', todoService)
        .run(run);
    " > public/js/app.js

        # Create mainController
        echo '// MAIN CONTROLLER
    function mainController($scope, $http, todoService) {
        $scope.title = "Todo List";

        function load(){
            todoService.get().then(function(res){
                $scope.todos = res.data;
            });
        }
        $scope.add = function(){
            var data = {};
            data.description = $scope.description;
            todoService.create(data).then(function(res){
                load();
            });
            $scope.description = "";
        }
        $scope.update = function(todo){
            todoService.update(todo._id, todo).then(function(res){
                load();
            });
        }
        $scope.delete = function(todo){
            todoService.delete(todo._id).then(function(res){
                load();
            });
        }
        load();
    }' > public/js/controllers/mainController.js


        # Create view main.html
        echo '<h1>{{title}}</h1>
    <form class="form-inline">
        <div class="form-group">
            <input type="text" class="form-control" id="inputMessage"
                   placeholder="Your task" ng-model="description">
        </div>
        <button type="submit" class="btn btn-default" ng-click="add()">Add</button>
    </form>
    <hr>
    <ul class="list-group">
        <li class="list-group-item" ng-repeat="todo in todos">
            <form class="form-inline">
                <div class="form-group">
                    <input type="text" class="form-control" id="inputMessage"
                           ng-model="todo.description">
                </div>
                <div class="pull-right">
                    <button type="submit" class="btn btn-default" ng-click="update(todo)">Update</button>
                    <button type="submit" class="btn btn-danger" ng-click="delete(todo)">Delete</button>
                </div>
            </form>
        </li>
    </ul>' > public/views/main.html

        echo "<h1>About</h1>" > public/views/about.html

        # Create Server
        echo "// set up ======================================================================
    var http            = require('http');
    var express            = require('express');
    var app                = express();
    var port            = process.env.PORT || 8000;            // set the port
    var morgan            = require('morgan');
    var bodyParser        = require('body-parser');
    var methodOverride    = require('method-override');
    // configuration ===============================================================
    app.use(express.static(__dirname + '/public'));
    app.use(morgan('dev'));
    app.use(bodyParser.urlencoded({'extended':'true'}));
    app.use(bodyParser.json());
    app.use(bodyParser.json({ type: 'application/vnd.api+json' }));
    app.use(methodOverride('X-HTTP-Method-Override'));
    // Mongoose ====================================================================
    require('./config/database');
    // Serveur ===================================================================
    var server = http.Server(app);
    // routes ======================================================================
    require('./app/routes')(app);
    process.on('SIGINT', function() {
      console.log('Stopping...');
      process.exit();
    });
    // listen (start app with node server.js) ======================================
    server.listen(port);
    console.log('Listening at http://127.0.0.1:'+port);
    " > server.js

    # Create route index.js
    echo "// ROUTES
    module.exports     = function(app) {
    'use strict';
    var fs   = require('fs');
    var path = require('path');
    fs.readdir('./app/routes', loadControllers);
    function loadControllers(error, files) {
        if (error)
          throw error;
        else
          files.forEach(requireController);
        // application -------------------------------------------------------------
        app.get('*', function(req, res) {
            res.sendFile(path.join(__dirname, '../../public', 'index.html')); // load the single view file (angular will handle the page changes on the front-end)
        });
    }
    function requireController(file) {
        // remove the file extension
        var controller = file.substr(0, file.lastIndexOf('.'));
        // do not require index.js (this file)
        if (controller !== 'index') {
          // require the controller
          require('./' + controller)(app);
        }
    }
    }" > app/routes/index.js

    # Create Todo route

    echo "// ROUTES TODOS
    var Todo = require('../models/todo.js');
    module.exports     = function(app) {

    app.get('/todos', Todo.findAll);
    app.post('/todos', Todo.create);
    app.put('/todos/:id', Todo.update);
    app.delete('/todos/:id', Todo.delete);

    }" > app/routes/todos.js

    # Create Todo model
    echo "// MODEL TODO
    var mongoose = require('mongoose');


    var todoSchema = new mongoose.Schema({
    description: String
    });

    var Todo = {

    model: mongoose.model('Todo', todoSchema),

    create: function(req, res) {
        Todo.model.create({
            description: req.body.description
        }, function(){
            res.sendStatus(200);
        })
    },

    findAll: function(req, res) {
        Todo.model.find(function (err, data) {
            res.send(data);
        });
    },

    update: function(req, res){
        Todo.model.findByIdAndUpdate(req.params.id, {
            description: req.body.description
        }, function(){
            res.sendStatus(200);
        })
    },

    delete: function(req, res){
        Todo.model.findByIdAndRemove(req.params.id, function(){
            res.sendStatus(200);
        })
    }
    }

    module.exports = Todo;" > app/models/todo.js

    echo '{
      "name": "mystack-init",
      "version": "1.0.0",
      "description": "This file will be removed soon",
      "license": "MIT",
      "author": "Jean-Baptiste Pasquier <contact@jbpasquier.eu>",
      "ignore": [
        "**/.*",
        "node_modules",
        "bower_components"
      ],
      "devDependencies": {
        "angular": "latest",
        "angular-animate": "latest",
        "angular-route": "latest",
        "bootstrap": "latest",
        "jquery": "latest"
      }
    }
    ' > bower.json
    echo '{
      "directory": "./public/bower/",
      "analytics": false
    }
    ' > .bowerrc
        clear
        npm init
        clear
        # NPM install
        npm install bower express bluebird config body-parser pluralize method-override morgan mongoose --save
        clear
        ./node_modules/bower/bin/bower install
        clear
        mv ./public/bower/angular/angular.min.js ./public/js/libs/
        mv ./public/bower/angular-animate/angular-animate.min.js ./public/js/libs/
        mv ./public/bower/angular-route/angular-route.min.js ./public/js/libs/
        mv ./public/bower/bootstrap/dist/js/bootstrap.min.js ./public/js/libs/
        mv ./public/bower/bootstrap/dist/css/bootstrap.min.css ./public/css/
        mv ./public/bower/bootstrap/dist/css/bootstrap-theme.min.css ./public/css/
        mv ./public/bower/bootstrap/dist/fonts/* ./public/fonts/
        mv ./public/bower/jquery/dist/jquery.min.js ./public/js/libs/
        rm -R ./public/bower
        rm ./bower.json
        rm ./.bowerrc
        cp ./config/database.js.sample ./config/database.js
        clear
        npm uninstall bower --save
        clear
        echo '---------------------------------------------'
        echo -e "$VERT" "You application created to folder : " "$response"
        echo -e "$ROUGE" "!! Configure you database in config/database.js" "$NORMAL"
        echo ''
        echo -e " RUN YOUR APP : " "$CYAN" " node server.js" "$NORMAL"
        echo '---------------------------------------------'
    else
        echo 'Ok!'
    fi
fi
exit 0
