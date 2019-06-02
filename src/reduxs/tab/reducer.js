import {
  LOADING_TAB,
  RECEIVE_TAB,
  CANCEL_CAMERA_ACCESS,
  ACTIVATE_CAMERA
} from "./actions";
import { tabConstants } from "./constants";

const initialState = {
  isLoading: false,
  tab: {},
  cameraAccess: true
};

export default (state = initialState, action) => {
  switch (action.type) {
    case tabConstants.FETCH_TAB_REQUEST: {
      return { ...state, loaded: action.payload };
    }
    case tabConstants.FETCH_TAB_SUCCESS: {
      console.log(action);
      return { ...state, data: action.payload.data, loaded: "false" };
    }
    case tabConstants.FETCH_TAB_FAIL: {
      return { ...state, data: action.payload.data, loaded: "false" };
    }
    default: {
      return state;
    }
  }
};
