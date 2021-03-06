import React, { useState } from "react";
import { useAuthForm } from "Api";
import { useNotifications } from "Notifications";
import { useHistory } from "react-router-dom";
import { useCallbackOnce, formatDate } from "Utility";

import { Button } from "react-bootstrap";
import { Form, Card } from "Components";
import { AppBase } from "Pages";

export default function CreateMovie() {
  const [isBlocking, setIsBlocking] = useState(true);
  const { toast } = useNotifications();
  const history = useHistory();
  const { isLoading, onSubmit } = useAuthForm({
    path: "/movies",
    onFailure: toast,
    onSuccess: () => {
      setIsBlocking(false);
      toast("Movie created successfully", "success");
    }
  });

  const onFormSubmit = useCallbackOnce(({ name, duration, releasedate }) =>
    onSubmit({
      name,
      duration,
      releasedate: formatDate(releasedate)
    })
  );

  return (
    <AppBase title="Create Movie" level="admin">
      <Card>
        <Form
          onSubmit={onFormSubmit}
          isShown
          isBlocking={isBlocking}
          isLoading={isLoading}
          reverseButtons
          submit={{
            variant: "secondary",
            text: "Create"
          }}
          buttons={
            <Button
              variant="outline-primary"
              onClick={() => history.push("/app")}
            >
              Back
            </Button>
          }
          entries={[
            { key: "name", name: "Name", required: true, width: 6 },
            {
              key: "duration",
              name: "Duration",
              width: 6,
              type: "numeric",
              required: true,
              defaultValue: "60",
              props: {
                min: 1
              }
            },
            {
              key: "releasedate",
              name: "Release Date",
              required: true,
              type: "date"
            }
          ]}
        />
      </Card>
    </AppBase>
  );
}
CreateMovie.displayName = "CreateMovie";
