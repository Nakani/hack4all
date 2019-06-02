import axiosInstance from ".";
import { ID_UNITY_DEV, Urls } from "../config/environments";

export default class {
  constructor() {
    this.instance = axiosInstance(Urls.REACT_APP_API_ORDERS);
  }

  getOrderDetails(id) {
    const request = {
      method: "GET",
      url: "/",
      params: {
        placeLabel: id,
        idUnity: ID_UNITY_DEV
      }
    };

    return this.instance(request);
  }
}
