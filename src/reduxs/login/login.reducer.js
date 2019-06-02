import { loginConstants } from "./data.constants";
const INITIAL_STATE = {
  loaded: false,
  data: []
};

export default (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case loginConstants.FETCH_LOGIN_REQUEST: {
      return { ...state, loaded: action.payload };
    }
    case loginConstants.FETCH_LOGIN_SUCCESS: {
      console.log(action);
      return { ...state, data: action.payload.data, loaded: "false" };
    }
    case loginConstants.FETCH_LOGIN_FAIL: {
      return { ...state, data: action.payload.data, loaded: "false" };
    }
    default: {
      return state;
    }
  }
};
