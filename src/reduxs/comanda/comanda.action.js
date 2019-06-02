import { comandaConstants } from "./comanda.constants";
import { getOrderDetails } from "../../services/Order";

export const getcomanda = idComanda => async dispatch => {
  try {
    dispatch({ type: comandaConstants.FETCH_COMANDA_REQUEST, payload: true });
    const comanda = await getOrderDetails(idComanda);
    if (comanda) {
      dispatch({
        type: comandaConstants.FETCH_COMANDA_SUCCESS,
        payload: { comanda }
      });
    } else {
      dispatch({ type: comandaConstants.FETCH_COMANDA_FAIL, payload: false });
    }
  } catch (err) {
    console.log(err);
  }
};
