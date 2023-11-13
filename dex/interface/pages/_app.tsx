/* eslint-disable react/display-name */
import 'react-loading-skeleton/dist/skeleton.css';

import { GoogleOAuthProvider } from '@react-oauth/google';
import { Analytics as VercelAnalytics } from '@vercel/analytics/react';
import { NextPage } from 'next';
import { AppProps } from 'next/app';
import Head from 'next/head';
import NextProgress from 'next-progress';
import { ReactNode, StrictMode } from 'react';

import { ThemeManager } from '@/components';

const MyApp = ({ Component, pageProps }: AppProps<NextPage>): ReactNode => (
  <>
    <Head>
      <title>Meta School</title>
      <meta
        name="viewport"
        content="width=device-width, initial-scale=1, maximum-scale=5, minimum-scale=1, viewport-fit=cover"
      />
    </Head>
    <NextProgress options={{ showSpinner: false }} />
    {/* TODO: change client id */}
    <GoogleOAuthProvider clientId="<your_client_id>">
      <ThemeManager>
        <StrictMode>
          <Component {...pageProps} />
          <VercelAnalytics />
        </StrictMode>
      </ThemeManager>
    </GoogleOAuthProvider>
  </>
);

export default MyApp;
