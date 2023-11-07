import Debug "mo:base/Debug";
import Text "mo:base/Text";
import HTTP "mo:base/HTTP";

actor TechShop {

  // A simple database of user credentials (for demonstration purposes)
  var users : HashMap.TextMap<Text.Text, Text.Text> = HashMap.empty;

  // Initialize the user database with some sample users
  users := HashMap.put("user1", "password1", users);
  users := HashMap.put("user2", "password2", users);

  public func main() : async {
    // Start the HTTP service
    HTTP.start_service();
  }

  service : HTTP.Request -> HTTP.Reply {
    public func accept(request: HTTP.Request) : async HTTP.Reply {
      switch (request.method, request.url.path) {
        case (HTTP.Method.Get, "/login") {
          // Serve the login form
          return HTTP.response(
            200,
            "text/html",
            "<html><body><form action='/login' method='post'>" ++
              "<input type='text' name='username' placeholder='Username'><br>" ++
              "<input type='password' name='password' placeholder='Password'><br>" ++
              "<input type='submit' value='Login'></form></body></html>",
          );
        };
        case (HTTP.Method.Post, "/login") {
          // Handle the form submission (user login)
          let body = request.body;
          let params = HTTP.parseFormBody(body);

          // Extract the submitted username and password
          let username = HashMap.getOrDefault("username", "", params);
          let password = HashMap.getOrDefault("password", "", params);

          // Check if the user exists in the database and the password matches
          switch (users[username]) {
            case (null) {
              // User does not exist
              return HTTP.response(401, "text/html", "Invalid username or password.");
            };
            case (userPassword) {
              if (userPassword == password) {
                // User is authenticated; you can set a session cookie or JWT token here
                return HTTP.response(200, "text/html", "Welcome, " # username # "!");
              } else {
                // Password is incorrect
                return HTTP.response(401, "text/html", "Invalid username or password.");
              };
            };
          };
        };
        case _ {
          return HTTP.response(404, "text/html", "Not Found");
        };
      };
    };
  };
};