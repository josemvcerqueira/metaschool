import { GoogleLogin } from '@react-oauth/google';
import { FC } from 'react';

const GoogleConnect: FC = () => (
  <GoogleLogin
    onSuccess={(credentialResponse) => {
      console.log(credentialResponse);
    }}
    onError={() => {
      console.log('Login Failed');
    }}
  />
);

export default GoogleConnect;
