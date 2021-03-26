# perl-mini-framework

Perl MVC Framework V1.0
-----------------------

A lightweight perl framework for building service based apis and application back ends. 

Influenced by the ideals behind MVC and REST services made popular by the PHP community in recent years, this perl framework is designed to promote code separation and a modular approach, entirely separate from any front end, whereby any front ends can simply call this api. It is purposefully extremely lightweight and easy to use, but this document should be fully read before starting.


Introduction
------------

API calls are based on 'URL-to-function' mapping. This mapping takes the initial parameters of the url and uses them to define and call a controller module and a function in that controller. Eg. localhost/auth/login will load the 'auth' controller and call the 'login' function in tha controller. The auth controller can be found at /controllers/auth.pm. Then, any further parts to the URL will automatically be turned into key value pairs (so /user/matt replaces ?user=matt or its POST equivilent) and these params are passed by default as paramaters into any controller function which is called in the framework through the url mapping. Thus auth/login/user/matt translates to auth.pm in the controllers folder, and the function 'login' in this file, which will have access to the value of the variable 'user' with the value of 'matt' without any further coding required to get the data there. New controllers and functions can be added as required with no further coding required to make them accessible as this is all done in the core. Unless the framework is being worked on, there should be no need to touch the core code at all. The core code itself can be found in the initial script which is called for every request (api.cgi), and in the /core folder off this folder. Additionally api.cgi is automatically called for all web requests as per the rules in the .htaccess file, regardless of the url path that is received. No other scripts in the folder are directly callable by the front end.

The framework promotes an MVC approach with built in URL to function mapping and ready made /controllers, /views and /models directories. Ideally, controllers should be kept fairly lightweight, and should call on models for business logic. A model should gather all the required data (via database connections or calls to external apis etc) and return its response to the controller. The controller should then return this to the main entry point (in this case, api.cgi), and a view (he V in MVC) will then be dynamically populated with the response. The default view is set in /core/base.pm, and this value can be overwritten if required by individual controllers for different types of output (eg. HTML, Json, XML, text). 


Writing code
------------

The default entry point is api.cgi and is found in the root directory. An .htaccess file routes all requests to the api folder to this script, so in the url you simply call the folder - eg /api/. The api.cgi script calls /core/route.pm to parse the url and return the required functions and parameters which are required for that api call. api.cgi will route the parameters to the correct place, then receive the response as a hash reference and pass this into the view for rendering. 

Adding a new feature requires a new subroutine to be written to deal with it - either in a new controller, or added to an existing controller. Controllers should be placed in the /controllers folder as perl modules with their own package namespace (named after the filename), and ideally should be named after the section of the app that they deal with, with get/add/update/search etc functions written into the controller as required. Example URLS might be:

/user/get/userid/12345 - to get data for a user with id 12345 from a function called 'get' in /controllers/userController.pm

/user/update/userid/12345 - to update data for a user from a sub called 'update' in /controllers/userController.pm. Alternatively, the simpler path of just user/update could be used here with the important params passed in as POST variables. 

/products/search/?query=productName - This format would find the 'search' sub in /controllers/productsController.pm.

/search/?query=productName - This format would find the 'defaultAction' sub in /controllers/searchController.pm as no function is specified as part of the url.

The framework does not dictate how to structure your code, but it is recommended to use a model or library function for business logic, and keep the controller fairly lightweight - dealing with program flow rather than business specific logic. Models or libraries can simply be required using perl's 'require' funciton by your controller as and when you need them.

The controller should build up a hash of data you wish to be placed into the view, and this should ALWAYS be returned as a HASH REFERENCE (normally \%response). Required keys in this has are outlined below. This reference is passed into the view through the main entry point - 'api.cgi' as $response. For JSON views, the 'content' key should contain key=>value pairs, which will be used exactly as is in a JSON view and sent to the front end, or parsed into a template using a standard template view. Template variables are specified in templates using {=variable_name}, and will be swapped out with the variable value as the template is parsed. See the documentation in lib/stl_parser for more information on 'simple template language' including writing basic 'if' statements directly into the view in case further data parsing is required. Template files themselves should be placed in /view/templates.


Example: Create a new controller called data, and a function in it called get (therefore accessible by calling 'api/data/get')
------------------------------------------------------------------------------------------------------------------------------

You first need to create a perl module called dataController.pm, and place it in the controllers folder. This package should be an instance of masterController (using perl's @isa functionality), and should contain a function called 'get'. Note that if just api/data is specified on the url, the framework will try and run a function called defaultAction() which you may also use as a default. If you don't create this function then the one in masterController.pm will be used instead. Currently this just displays a default error message (your new module IS A (@isa) masterController, so this function is inherited). You can also use the defaultAction to return usage information for the controller if you wish, such as how the module should be used, which functions can be called, which data can be sent.

Start the controller file as follows:

  1 #!/usr/bin/perl

  2 # dataController.pm

  3 

  4 package dataController;

  5 @ISA = (masterController);

Using @ISA in this way will automatically add functions called new and defaultAction so technically this should work as it is. An AUTOLOAD function in the masterController will return a default 404 error for any non-existent functions which are called too. 

The 'get' subroutine should return a hash to its caller in api.cgi with the following keys set: 
	error 		(bool 0/1), 
	success 	(bool 0/1), 
	errorMessage 	(string if populated, or 0), 
	content 	(This can be either a further hash of values which can be sent as json to a json view, or free text/html which can be placed in a template using the 
			 default template view to return preformatted HTML directoy)

To change the default view
--------------------------
Simply add one of the following lines in your function in the controller: 

viewController::setContentType("text/html"); viewController::setView("view_template");    - to turn on a the default simple templated view, or 

viewController::setContentType("application/json"); viewController::setView("view_json"); - to turn on a json view. 

Either of these may be set as default in config.cgi however. The default view is currently JSON. 


Accessing url params and request variables 
------------------------------------------
Data can be picked up anywhere in your code but only by following the framework. 

Params sent in as part of the URL are stored in a hash (by route.pm) as the url is parsed, and can be accessed from the built in accessor methods route::get_key_pairs (all pairs) and route::get_route_value(keyName) ( to get a single value for a single key). 

They are also passed into any top level controller fuction (one which is called from the url) by default as a hashref called 'pairs',which can be 'shifted' off the calling arguments as follows:


sub myFunction(){

 	my $self = shift; 

	my $inputs = shift; 

	my $parameter_value = $inputs->{'pairs'}->{'parameter_name'};

}


Using JSON for creating API / Service based architectures
---------------------------------------------------------

Json is supported by the view_json.pm file in /views. This will convert any data you throw at it into json format.
If you are displaying json data, the content-type of the output must be set to application/json - this is done by default in the initial api.cgi script. 

The json view will return the following params by default:

error: 		Bool (1/0)

success: 	Bool (1/0) - Both error and success can be set and should always be opposite to each other.

errorMessage: 	String. This should contain any error message returned by your code. 

content: 	JSON. The content key will contain the json that you actually want to return.


Initial configuration
---------------------
Configuration settings should all go into /config.cgi, and specified using 'our' so they can be shared with your code. There are very few required configuration settings, but two are notable:

	$path (string) - The path by which your api is called. This could simply be "api" which would relate to /api, here it is 'api' with the auth->login controller function found at api/controllers/authController.pm in function login(), and called by /api/auth/login/.  

	$login_required (bool) - forces a login message if the user is not logged in irrespective of what controller is called.

	$default_content_type (string) - should be application/json for JSON based APIs, and standard text/html for traditional web use. 

Database settings and your own configurations can be placed into this file as well.



Folder structure
----------------
/controllers - All user defined controller functions should be in here, in the root directory (may be changed to sub-dirs by modifying core scripts).

/core - core framework files, inc base.

/data - data storage eg. text files as you require.

/lib - library functions. These may be general library modules or specific ones (eg. for external data via SOAP/Curl calls, loading in data from modules etc)

/models - model functions, which should be related to database or data storage.

/views - perl files for rendering a view. These will take the output from the controller, render, and finally print.

/views/templates - templates in which to render a view should perl code not be enough. These may be HTML templates with placeholders in which to insert dynamic data.


