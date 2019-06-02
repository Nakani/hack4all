import { login, getTabDetails } from "../../../reduxs/index";
const mapStateToProps = store => {
  const { lists } = store;
  return lists;
};

const mapDispatchToProps = {
  login,
  getTabDetails
};
export const maps = {
  mapStateToProps,
  mapDispatchToProps
};
