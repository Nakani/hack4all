import { getListDetail } from '../../../../reduxs';
const mapStateToProps = store => {
  const { detail } = store
  return detail
};

const mapDispatchToProps = {
  getListDetail,
}
export const maps = {
  mapStateToProps,
  mapDispatchToProps
}
