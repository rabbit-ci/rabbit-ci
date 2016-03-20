import Ember from "ember";
import ENV from "../config/environment";
import Phoenix from "../phoenix";

export default {
  name: "phoenix-adapter",
  after: "store",

  initialize: function(application) {
    const uri = ENV.SocketURI;

    if (uri === undefined || uri === null) {
      console.error("You must specify a `SocketURI` in your config/environment.js file");
    } else {
      const phoenix = new Phoenix.Socket(uri, {});
      phoenix.connect();

      application.register("store:phoenix", phoenix, { instantiate: false });
      application.inject("model", "phoenix", "store:phoenix");
    }
  }
};
