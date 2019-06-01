import { listsConstants } from './lists.constants'
import { requisitionsService } from '../../services/requisitions'

export const getLists = () => async (dispatch) => {
  try {
    dispatch({ type: listsConstants.FETCH_LISTS_REQUEST, payload: true })
    const lists = await requisitionsService.getListsAll()
    if (lists) {
      dispatch({ type: listsConstants.FETCH_LISTS_SUCCESS, payload: { lists } })
    } else {
      dispatch({ type: listsConstants.FETCH_LISTS_FAIL, payload: false })
    }
  }
  catch (err) {
    console.log(err)
  }
}
