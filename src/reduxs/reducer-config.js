import { combineReducers } from "redux";
import paymentMethod from "./paymentMethod/reducer";
import auth from "./auth/reducer";
import tab from "./tab/reducer";

const rootReducer = combineReducers({
  auth,
  paymentMethod,
  tab
});

export default rootReducer;
