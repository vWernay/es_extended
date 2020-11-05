import React from "react";
import "./App.css";
import { useStatusService } from "./components/hooks/useStatusService";
import StatusCircle from "./components/StatusCircle";
import { useNuiService } from "./nui-events/hooks/useNuiService";


// setTimeout(() => {
//   window.dispatchEvent(
//     new MessageEvent("message", {
//       data: {
//         app: 'STATUS',
//         method: 'setStatus',
//         data: [
//           {
//             id: 1,
//             color: 'blue',
//             value: 50,
//             icon: 'fa-car',
//             iconType: 'fontawesome'
//           },
//           {
//             id: 2,
//             color: 'orange',
//             value: 75,
//             icon: 'fastfood',
//             iconType: 'material'
//           }
//         ]
//       }
//     })
//   )
// }, 1000)

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
