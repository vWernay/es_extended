import React from "react";
import "./App.css";
import { useStatusService } from "./components/hooks/useStatusService";
import StatusCircle from "./components/StatusCircle";
import { useNuiService } from "./nui-events/hooks/useNuiService";


setTimeout(() => {
  window.dispatchEvent(
    new MessageEvent("message", {
      data: {
        app: "STATUS",
        method: "setStatus",
        data: [
          {
            id: 1,
            color: "#ff9800",
            value: 10,
            icon: "fastfood",
            iconType: "material",
          },
          {
            id: 2,
            color: "#2196f3",
            value: 75,
            icon: "opacity",
            iconType: "material",
          },
          {
            id: 3,
            color: "#ec407a",
            icon: "fa-brain",
            iconType: "fontawesome",
            value: 25,
          },
        ]
      }
    })
  )
}, 1000)

function App() {
  useNuiService();
  useStatusService();
  return (
    <div className="App">
      <StatusCircle />
    </div>
  );
}

export default App;
