import React from "react";

import { Layout } from "Components";
import { Login } from "Pages";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import { Container } from "react-bootstrap";

function App() {
  return (
    <Router>
      <Layout>
        <Container>
          <Switch>
            <Route exact path="/">
              <Login />
            </Route>
          </Switch>
        </Container>
      </Layout>
    </Router>
  );
}

export default App;
