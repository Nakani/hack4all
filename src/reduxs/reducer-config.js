import { combineReducers } from 'redux'
import listReducer from './lists/lists.reducer'
import detailReducer from './detail/detail.reducer'

const rootReducer = combineReducers({
  lists: listReducer,
  detail: detailReducer,
})

export default rootReducer
