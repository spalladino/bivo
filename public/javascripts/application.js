// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function disableAndContinue(element, text) {
    window.setTimeout(function(){
        $(element).attr({ disabled:true, value: text});
    },0);
}

