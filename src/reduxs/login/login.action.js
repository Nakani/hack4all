import { loginConstants } from "./login.constants";
import { requisitionsService } from "../../services/requisitions";

export const getLogin = () => async dispatch => {
  try {
    dispatch({ type: loginConstants.FETCH_LOGIN_REQUEST, payload: true });
    const login = await requisitionsService.getLoginAll();
    if (login) {
      dispatch({
        type: loginConstants.FETCH_LOGIN_SUCCESS,
        payload: { login }
      });
    } else {
      dispatch({ type: loginConstants.FETCH_LOGIN_FAIL, payload: false });
    }
  } catch (err) {
    console.log(err);
  }
};
