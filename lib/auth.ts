import {cookies} from 'next/headers'; import {SignJWT,jwtVerify} from 'jose';
const key=()=>new TextEncoder().encode(process.env.JWT_SECRET!);
export async function hashPassword(p:string){const crypto=await import('crypto');return crypto.scryptSync(p,'emsell-salt',64).toString('hex')}
export async function verifyPassword(p:string,h:string){return (await hashPassword(p))===h}
export async function signSession(x:{id:string,email:string,isAdmin:boolean}){return new SignJWT(x).setProtectedHeader({alg:'HS256'}).setIssuedAt().setExpirationTime('30d').sign(key())}
export async function getSession(){const t=(await cookies()).get('emsell_session')?.value;if(!t)return null;try{return (await jwtVerify(t,key())).payload as unknown as {id:string,email:string,isAdmin:boolean}}catch{return null}}
export async function setSession(x:{id:string,email:string,isAdmin:boolean}){const t=await signSession(x);(await cookies()).set('emsell_session',t,{httpOnly:true,secure:true,sameSite:'lax',maxAge:2592000,path:'/'})}
export async function clearSession(){(await cookies()).delete('emsell_session')}