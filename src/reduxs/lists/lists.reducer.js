import { listsConstants } from './lists.constants'
const INITIAL_STATE = {
  loaded: false,
  lists: [],
}

export default (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case listsConstants.FETCH_LISTS_REQUEST: {
      return { ...state, loaded: action.payload }
    }
    case listsConstants.FETCH_LISTS_SUCCESS: {
      return { ...state, lists: action.payload.lists, loaded: 'false' }
    }
    case listsConstants.FETCH_LISTS_FAIL: {
      return { ...state, lists: action.payload.lists, loaded: 'false' }
    }
    default: {
      return state
    }
  }
}
