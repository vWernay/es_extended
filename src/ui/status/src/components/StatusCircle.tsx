import React, { useState } from "react";
import "../App.css"
import CircularProgress from "@material-ui/core/CircularProgress";
import { createStyles, makeStyles, Theme } from "@material-ui/core/styles";
import Fab from "@material-ui/core/Fab";
import { useStatus } from "./hooks/useStatus";
import Switch from '@material-ui/core/Switch';
import Fade from '@material-ui/core/Fade';
import FormControlLabel from '@material-ui/core/FormControlLabel';

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    fabProgress: {
      position: "absolute",
      margin: 15,
      left: -17,
      bottom: -17,
    },
    wrapper: {
      margin: theme.spacing(1),
      position: "relative",
    },
  })
);

/*
75%, 50%, 25%, 20, 15, 10, 5, 0
And 100
*/

function StatusCircle(): any {
  const status = useStatus();
  const classes = useStyles();

  let fadeValue = [100, 75, 50, 25, 20, 15, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

  return (
    <div
      className="App"
      style={{ display: "flex", position: "absolute", right: 14, bottom: 20 }}
    >
      {status.map((stat) => (
        <Fade in={fadeValue.includes(stat.value)}>
          <div key={stat.id} className={classes.wrapper}>
            <Fab style={{ background: "#232323" }} size="medium">
              {stat.iconType === "material" ? (
                <i style={{ color: stat.color }} className="material-icons">
                  {stat.icon}
                </i>
              ) : (
                <i
                  style={{ color: stat.color }}
                  className={`fa ${stat.icon}`}
                ></i>
              )}
            </Fab>
            <CircularProgress
              style={
                stat.value <= 10 ? { color: "#d63031" } : { color: stat.color }
              }
              variant="static"
              size={52}
              thickness={5}
              value={stat.value}
              className={classes.fabProgress}
            />
          </div>
        </Fade>
      ))}
    </div>
  );
}

export default StatusCircle;
