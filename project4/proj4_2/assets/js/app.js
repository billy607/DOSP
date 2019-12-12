// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
//import socket from "./socket"
import socket from "./socket"
import Register from "./register"
import Login from "./login"

var active_page = window.location.href;
    active_page = active_page.substr(active_page.lastIndexOf('/')+1);
    switch (active_page) {
      case "register":
        Register.init(socket)
        break;
      case "login":
        Login.init(socket)
        break;
      default:
          break;
    };