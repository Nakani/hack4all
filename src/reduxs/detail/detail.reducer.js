import { detailConstants } from './detail.constants'
const INITIAL_STATE = {
  loaded: false,
  lists: [],
}

export default (state = INITIAL_STATE, action) => {

  switch (action.type) {
    case detailConstants.FETCH_DETAIL_REQUEST: {
      return { ...state, loaded: action.payload }
    }
    case detailConstants.FETCH_DETAIL_SUCCESS: {
      return { ...state, detail: action.payload.detail, loaded: 'false' }
    }
    case detailConstants.FETCH_DETAIL_FAIL: {
      return { ...state, detail: action.payload.detail, loaded: 'false' }
    }
    default: {
      return state
    }
  }
}
