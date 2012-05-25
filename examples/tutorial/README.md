= Eiffel Web Framework =

== Why would you use the Eiffel Web Framework ? ==
To enjoy the advantage of the Eiffel technology (language, DbC, methods, tools)
To write once and run on any web server, on any platforms thanks to the notion of connector.

== What is a connector? ==
A connector is the layer between the underlying httpd server, and your application based on EWF.
Currently, 3 connectors are available within EWF (but others are available outside).
­ CGI: the common CGI application (apache, iis, ...)
- FastCGI: on any server supporting libfcgi handling (apache, iis, ...)
- Nino: using the standalone Eiffel Web Nino server, you can run anywhere easily, and debug simply with EiffelStudio's debugger

Supporting a new connector is fairly simple, it just has to support the simple EWSGI specification which is really small. Then EWF will bring the power on top of it.

So you can build your application and be sure you will be able to run it ... anywhere thanks to the conceіpt of connectors.

== EWSGI specification ==
EWF relies on a small core specification, named EWSGI (Eiffel Web Servєr Gateway Interface). 
It is very limited on purpose to allow building new connector very easily.

For now, you just need to know EWF is compliant with EWSGI specification.

= Tutorial =

Now let's discover the Eiffel Web Framework with this tutorial.
1 - You will learn first, how to get and install EWF.
2 - build a simple Hello World application
3 - use the query and form parameter to build dynamic service
4 - And you will learn how to dispatch URL

== Get EWF package ==
=== From the archive ===
- to be completed

=== From the source ===
- Requirement: install git on your machine  (http://www.git-scm.org/)

	git clone --recursive https://github.com/EiffelWebFramework/EWF.git ewf

And that's it  for now.

== Install EWF ==
For now, there is nothing specific to do.

(Note: if you want to use the "http_client" library, you will need to do a few extra steps to eventually compile Eiffel Curl.)

== Step 1 ==

== Step 2 ==

== Step 3 ==

== Step 4 ==



