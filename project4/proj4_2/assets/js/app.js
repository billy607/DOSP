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
import Main from "./main"
import Delete from "./delete"

var active_page = window.location.href;
    active_page = active_page.substring(active_page.lastIndexOf('/')+1,active_page.lastIndexOf('/')+5);
    switch (active_page) {
      case "regi":
        Register.init(socket)
        break;
      case "logi":
        Login.init(socket)
        break;
      case "main":
        Main.init(socket)
        break;
      case "dele":
        Delete.init(socket)
        break;
      default:
          break;
    };