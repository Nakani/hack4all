import { detailConstants } from './detail.constants'
import { requisitionsService } from '../../services/requisitions'

export const getListDetail = (id) => async (dispatch) => {
  try {
    dispatch({ type: detailConstants.FETCH_DETAIL_REQUEST, payload: true })
    const detail = await requisitionsService.getDetailList(id)
    if (detail) {
      dispatch({ type: detailConstants.FETCH_DETAIL_SUCCESS, payload: { detail } })
    } else {
      dispatch({ type: detailConstants.FETCH_DETAIL_FAIL, payload: false })
    }
  }
  catch (err) {
    console.log(err)
  }
}
