import { describe, it, beforeEach, expect } from 'vitest';
import { Client, Provider, ProviderRegistry, Result } from '@stacks/transactions';
import { principalCV, uintCV, trueCV } from '@stacks/transactions/dist/clarity/types/principalCV';

const CONTRACT_NAME = 'meme-voting';
const DEPLOYER_ADDRESS = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
const USER1_ADDRESS = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
const USER2_ADDRESS = 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC';

describe('meme-voting contract test suite', () => {
  let client: Client;
  let provider: Provider;
  
  beforeEach(() => {
    provider = await ProviderRegistry.createProvider();
    client = new Client(CONTRACT_NAME, DEPLOYER_ADDRESS, provider);
  });
  
  describe('submit-meme', () => {
    it('should successfully submit a meme', async () => {
      const tx = client.createTransaction({
        method: { name: 'submit-meme', args: [] }
      });
      const receipt = await tx.sign(USER1_ADDRESS).broadcast();
      const result = Result.unwrap(receipt);
      expect(result).toBeTruthy();
      expect(result.value).toBeTypeOf('number');
    });
  });
  
  describe('vote-for-meme', () => {
    it('should successfully vote for a meme', async () => {
      // First, submit a meme
      const submitTx = client.createTransaction({
        method: { name: 'submit-meme', args: [] }
      });
      const submitReceipt = await submitTx.sign(USER1_ADDRESS).broadcast();
      const memeId = Result.unwrap(submitReceipt).value;
      
      // Then, vote for the meme
      const voteTx = client.createTransaction({
        method: { name: 'vote-for-meme', args: [uintCV(memeId)] }
      });
      const voteReceipt = await voteTx.sign(USER2_ADDRESS).broadcast();
      const result = Result.unwrap(voteReceipt);
      expect(result).toBeTruthy();
      expect(result.value).toBe(trueCV());
    });
    
    it('should fail when voting for a non-existent meme', async () => {
      const tx = client.createTransaction({
        method: { name: 'vote-for-meme', args: [uintCV(999)] }
      });
      const receipt = await tx.sign(USER1_ADDRESS).broadcast();
      expect(receipt.error).toBeTruthy();
      expect(receipt.error.reason).toContain('ERR_NOT_FOUND');
    });
    
    it('should fail when voting for the same meme twice', async () => {
      // Submit a meme
      const submitTx = client.createTransaction({
        method: { name: 'submit-meme', args: [] }
      });
      const submitReceipt = await submitTx.sign(USER1_ADDRESS).broadcast();
      const memeId = Result.unwrap(submitReceipt).value;
      
      // Vote for the meme
      const voteTx1 = client.createTransaction({
        method: { name: 'vote-for-meme', args: [uintCV(memeId)] }
      });
      await voteTx1.sign(USER2_ADDRESS).broadcast();
      
      // Try to vote again
      const voteTx2 = client.createTransaction({
        method: { name: 'vote-for-meme', args: [uintCV(memeId)] }
      });
      const receipt = await voteTx2.sign(USER2_ADDRESS).broadcast();
      expect(receipt.error).toBeTruthy();
      expect(receipt.error.reason).toContain('ERR_ALREADY_VOTED');
    });
  });
  
  describe('get-meme', () => {
    it('should return meme details', async () => {
      // Submit a meme
      const submitTx = client.createTransaction({
        method: { name: 'submit-meme', args: [] }
      });
      const submitReceipt = await submitTx.sign(USER1_ADDRESS).broadcast();
      const memeId = Result.unwrap(submitReceipt).value;
      
      // Get meme details
      const tx = client.createQuery({
        method: { name: 'get-meme', args: [uintCV(memeId)] }
      });
      const result = await tx.sign(USER1_ADDRESS).broadcast();
      const memeDetails = Result.unwrap(result);
      
      expect(memeDetails).toBeTruthy();
      expect(memeDetails.creator).toEqual(principalCV(USER1_ADDRESS));
      expect(memeDetails.votes).toEqual(uintCV(0));
      expect(memeDetails.reward).toEqual(uintCV(0));
    });
  });
  
  describe('get-meme-count', () => {
    it('should return the correct meme count', async () => {
      // Submit two memes
      const submitTx1 = client.createTransaction({
        method: { name: 'submit-meme', args: [] }
      });
      await submitTx1.sign(USER1_ADDRESS).broadcast();
      
      const submitTx2 = client.createTransaction({
        method: { name: 'submit-meme', args: [] }
      });
      await submitTx2.sign(USER2_ADDRESS).broadcast();
      
      // Get meme count
      const tx = client.createQuery({
        method: { name: 'get-meme-count', args: [] }
      });
      const result = await tx.sign(USER1_ADDRESS).broadcast();
      const memeCount = Result.unwrap(result);
      
      expect(memeCount).toEqual(uintCV(2));
    });
  });
});
