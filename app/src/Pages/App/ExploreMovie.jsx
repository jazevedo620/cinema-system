import React, { useMemo, useRef, useCallback, useState } from "react";
import { formatDate, identity, useCallbackOnce, isDefined } from "Utility";
import { useAuthGet, performAuthRequest } from "Api";
import { useNotifications } from "Notifications";
import { useAuth } from "Authentication";

import { AppBase } from "Pages";
import { Circle } from "rc-progress";
import { Form as BootstrapForm } from "react-bootstrap";
import { Placeholder, DataGrid, Icon, Form } from "Components";
import {
  AddressFormatter,
  ComboFilter,
  PopoverFilter
} from "Components/DataGrid";

import { primaryColor } from "global.json";

const MAX_DAILY_VIEWS = 3;

export default function ExploreMovie() {
  // Fetch views from API
  const { toast } = useNotifications();
  const [{ views }, { isLoading: viewsLoading }] = useAuthGet({
    route: "/movies/views",
    defaultValue: { views: [] },
    onFailure: toast
  });

  // Calculate views from today to display for quota
  const viewsToday = useMemo(() => {
    const today = formatDate(new Date());
    return views.filter(({ playdate }) => playdate === today).length;
  }, [views]);
  const quotaPercentage = (viewsToday / MAX_DAILY_VIEWS) * 100;

  // Fetch movies
  const [{ movies }, { isLoading: moviesLoading }] = useAuthGet({
    route: "/movies/explore",
    defaultValue: { movies: [] },
    onFailure: toast
  });

  // Fetch company names
  let [{ companies }] = useAuthGet({
    route: "/companies",
    config: { params: { only_names: true } },
    defaultValue: { companies: [] }
  });

  // Use ref to bypass incorrect generation usage
  const companyNameRef = useRef([]);
  companyNameRef.current = companies;

  // Column definitions
  const baseColumn = {
    sortable: true,
    filterable: true,
    resizable: true
  };
  const columns = [
    {
      key: "moviename",
      name: "Movie Name"
    },
    {
      key: "theatername",
      name: "Theater"
    },
    {
      key: "street",
      name: "Address",
      formatter: AddressFormatter,
      filterRenderer: PopoverFilter,
      popoverFilter: PopoverFilter.Address
    },
    {
      key: "companyname",
      name: "Company",
      filterRenderer: props => (
        <ComboFilter options={companyNameRef.current} {...props} />
      )
    },
    {
      key: "date",
      name: "Play Date",
      filterRenderer: PopoverFilter,
      popoverFilter: PopoverFilter.Date
    }
  ].map(c => ({ ...baseColumn, ...c }));

  // Credit card number selection combo box
  const [creditCard, setCreditCard] = useState(null);
  const onChangeCreditCard = useCallbackOnce((_, e) => setCreditCard(e));
  const [{ creditCards }, { isLoading: creditCardsLoading }] = useAuthGet({
    route: "/users/credit-cards",
    defaultValue: { creditCards: [] },
    onSuccess: ({ creditCards }) => {
      if (isDefined(creditCards) && creditCards.length > 0) {
        console.log("called");
        console.log(creditCards[0]);
        setCreditCard({ label: creditCards[0], value: creditCards[0] });
      }
    }
  });

  // Watch button
  const { token } = useAuth();
  const watch = useCallback(
    movie => {
      console.log({
        moviename: movie.moviename,
        releasedate: movie.releasedate,
        playdate: movie.date,
        theatername: movie.theatername,
        companyname: movie.companyname,
        creditcardnum: creditCard.value
      });
      performAuthRequest("/movies/views", "post", token, {
        config: {
          data: {
            moviename: movie.moviename,
            releasedate: movie.releasedate,
            playdate: movie.date,
            theatername: movie.theatername,
            companyname: movie.companyname,
            creditcardnum: creditCard.value
          }
        },
        onSuccess: () => {
          toast(
            `Movie ${movie.moviename} successfully viewed on ${movie.date}`,
            "success"
          );
          // TODO add to views
        },
        onFailure: toast,
        retry: false
      });
    },
    [creditCard, toast, token]
  );

  return (
    <AppBase title="Explore Movie" level="customer">
      <div className="explore-movie__watch">
        <h4 className="explore-movie__watch-label">Daily Watch Limit</h4>
        <div className="explore-movie__watch-progress">
          <Circle
            percent={quotaPercentage}
            strokeWidth="8"
            strokeColor={primaryColor}
          />
          <div className="explore-movie__watch-progress-label-wrapper">
            <Placeholder.Text
              className="explore-movie__watch-progress-label h4"
              text={viewsLoading ? null : viewsToday.toString()}
              size="2.5rem"
              width={40}
              auto
            />
          </div>
        </div>
      </div>
      <div className="explore-movie__credit-card">
        <BootstrapForm.Group>
          <BootstrapForm.Label>Credit Card:</BootstrapForm.Label>
          <Form.Input
            type="combo"
            inputKey={null}
            placeholder={"Select credit card"}
            onChange={onChangeCreditCard}
            value={creditCard}
            onBlur={identity}
            onKeyDown={identity}
            isClearable={false}
            options={creditCards}
            disabled={creditCardsLoading}
            isInvalid={!creditCardsLoading && creditCards.length === 0}
            message={"You must have at least one credit card to view a movie"}
          />
        </BootstrapForm.Group>
      </div>
      <DataGrid
        data={movies}
        columns={columns}
        canDeleteRow={() => false}
        columnWidths={{
          base: [180, 160, 300, 180, 200],
          "992": [180, 130, 300, 180, 190],
          "1200": [230, 130, 300, 200, null]
        }}
        isLoading={moviesLoading}
        getRowActions={row => {
          if (
            moviesLoading ||
            viewsToday >= MAX_DAILY_VIEWS ||
            creditCards.length === 0
          )
            return [];
          else
            return [
              {
                icon: <Icon name="arrow-circle-right" size="lg" noAutoWidth />,
                callback: () => watch(row)
              }
            ];
        }}
      />
    </AppBase>
  );
}
ExploreMovie.displayName = "ExploreMovie";
